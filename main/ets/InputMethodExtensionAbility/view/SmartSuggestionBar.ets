/**
 * 最顶部的正在输入的消息框
 */
import { correctKeyButtonDataSelectStr, KeyButtonData } from '../data/KeyButtonDataManager'
import { inputMethod } from '@kit.IMEKit'
import {
  convert2SuggestWord,
  getPinyinList,
  getPreviewTextLockedState,
  getUpdatePinyinGroup,
  isFullPinyin,
  PinyinSuggestResult,
  PreviewTextLockedState,
  spellToWord
} from '../util/SpellToWordUtil'
import keyboardController from '../model/KeyboardController'
import { PinyinDataSource, PinyinGroup, WordSuggestDataSource } from '../dao/DataSouce'
import { Queue, Stack, util } from '@kit.ArkTS'
import Logger from '../util/Logger'
import { CN_SUB_TYPE_ID, US_SUB_TYPE_ID } from '../constant/InputMethConstant'
import { smartSelectChar, smartSetNextStrSeg } from '../data/PinYinTrieNode'
import { getLongNineGridKeyCode } from '../data/NineGridKeyCodeManager'
import GlobalContext from '../context/GlobalContext'
import { isEnglishMode } from '../util/InputMethodUtil'


/**
 * 智能联想栏
 */
interface IPreviewText {
  previewTextArray: Array<PreviewText>;
  previewStr: string;
}


@Component
export struct SmartSuggestionBar {
  // @State inputContent:Array<KeyButtonData> = []

  // @State @Watch("onInputUpdate")  inputContent:Array<KeyButtonData> = []
  @Consume @Watch("onInputUpdate") inputContent: Array<KeyButtonData>
  // 是否展示联想词
  @State suggestMode: boolean = false;
  // 联想词资源
  // @State words:Array<SuggestionWord> = []
  @Consume pinyinList: PinyinDataSource;
  suggestWords: WordSuggestDataSource = new WordSuggestDataSource()
  // 是否正在展示拼音列表界面
  @Consume showPinYinListPage: boolean;
  @Consume @Watch("onInputUpdate") previewTextUpdate: boolean;
  @State previewTextList: Array<PreviewText> = []
  // 具体拼音Grid界面展示的拼音对应的联想词
  @Consume pageWords: WordSuggestDataSource
  // 当前页数
  pageIndex: number = 1;
  // 联想词页面大小
  pageSize: number = 40;
  // 是否展示表情面板
  @Consume showEmojiPanel: boolean;
  suggestWordScroller: Scroller = new Scroller()
  previewTextScroller: Scroller = new Scroller()

  build() {
    Row() {
      Column() {
        // 顶部的正在输入内容
        this.smartSuggestionText()
        // 联想词列表
        if (!this.showPinYinListPage) {
          this.suggestionList()
        }

      }.width('100%')
    }.width('100%')
  }

  /**
   * 顶部的正在输入内容
   */
  @Builder
  smartSuggestionText() {
    // 顶部的正在输入内容
    Row() {
      Row() {
        List({ scroller: this.previewTextScroller }) {
          ForEach(this.previewTextList, (item: PreviewText, index: number) => {
            ListItem() {
              Text(item.str).decoration({ type: item.lock ? TextDecorationType.Underline : TextDecorationType.None })
                .fontSize(16).fontColor(Color.Black)
            }
          }, (item: PreviewText, index) => item.id)
        }.listDirection(Axis.Horizontal).backgroundColor(Color.Transparent)

        .alignListItem(ListItemAlign.Center)
      }
      .height('100%')
      .backgroundColor('#ecf3fd')
      .constraintSize({ maxWidth: '50%' })
      .justifyContent(FlexAlign.Center)
      .margin({ left: 16 })
      .padding({ left: 2, right: 2 })

      Blank()
    }.height(20).width('100%')
    .backgroundColor(Color.Transparent).justifyContent(FlexAlign.Start)
  }

  /**
   * 联想词列表
   */
  @Builder
  suggestionList() {
    Row() {
      if (this.suggestMode) {
        List({ scroller: this.suggestWordScroller }) {
          LazyForEach(this.suggestWords, (item: SuggestionWord, index) => {
            ListItem() {
              Button(item.showName)
                .fontSize(24)
                .fontWeight(300)
                .type(ButtonType.Normal)
                .backgroundColor(Color.Transparent)
                .fontColor(0 == index ? '#437fe5' : Color.Black)
                .height('100%')
                .onClick(() => {
                  this.onSuggestClick(item.keys, item)
                  Logger.info(`点击的候选词: pinyin ${item.previewText} `)
                  this.previewTextUpdate = !this.previewTextUpdate
                })
            }
          }, (item: SuggestionWord, index: number) => item.id)
        }
        .layoutWeight(1)
        .height('100%')
        .padding(5)
        .listDirection(Axis.Horizontal)

        .onReachEnd(() => {
          this.loadMoreData()
        })

        // 显示具体拼音界面
        Button() {
          Image($r('app.media.to_right'))
        }.width(40).height(40).backgroundColor(Color.Transparent)
        .onClick(() => {
          this.showPinYinListPage = true;
          // 加载第一页文字
          // 更新左侧拼音列表
          this.changePinyinGroup()
          // 加载拼音详情页数据
          this.loadPinyinPageInfoData()
        })
      } else {
        InputToolBar()
      }


    }.width('100%').height(40).justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.Transparent)
  }

  /**
   * 加载拼音详情页数据
   */
  loadPinyinPageInfoData() {
    // 判断当前是不是完整拼音
    let previewText = GlobalContext.getContext().getPreviewText()
    // 更新联想词列表- 不进行分页查询
    getAssociationWord(1, 100, previewText, this.inputContent, (suggestWords) => {
      let append: boolean = suggestWords.append
      Logger.info(`共查询到${suggestWords.words.length}个联想词`)
      if (append) {
        this.pageWords.appendAllData(suggestWords.words, true)
      } else {
        this.pageWords.replaceAllData(suggestWords.words)
      }
    })
  }

  /**
   * 更新已选择的联想词状态为已选择, 不再参与词语联想
   * @param keys
   */
  onSuggestClick(keys: KeyButtonData[], suggestWord: SuggestionWord) {
    keys.forEach((value, index) => {
      if (value) {
        value.createWord = true
        value.createWordId = suggestWord.id
      }
    })
    // 清空联想词相关按键
    let context = GlobalContext.getContext()
    context.addUseWords(suggestWord)

    // 判断本次输入是否已完成
    let suggestNineGridCode = context.getUseWordsNineGridKeyCode()
    let previewTextNineGridCode = getLongNineGridKeyCode(this.inputContent)
    let completeInput: boolean = suggestNineGridCode.length >= previewTextNineGridCode.length
    // && previewTextNineGridCode.startsWith(suggestNineGridCode);

    // 输入完成，清空已输入按钮
    if (completeInput) {
      this.inputContent = []
      GlobalContext.getContext().clearUseWord()
      this.previewTextList = []
      // 添加文字进入输入框
      keyboardController.insertText(suggestWord.showName);
    }
    Logger.info(`当前联想词的九宫格编码为: ${suggestNineGridCode},  预览文本的九宫格编码为: ${previewTextNineGridCode}, 完成一次输入:${completeInput}`)
  }

  getLoadShowInputContent(pinyinGroups: PinyinGroup[]): IPreviewText {
    if (!pinyinGroups) {
      return { previewTextArray: [], previewStr: '' }
    }
    let bestMatchPinyin = pinyinGroups[0]?.name
    if (!bestMatchPinyin) {
      return { previewTextArray: [], previewStr: '' }
    }
    let pinyinStack: Queue<string> = new Queue()
    Array.from(bestMatchPinyin).forEach((value) => {
      pinyinStack.add(value)
    })

    let showText: Array<PreviewText> = []
    // 旧的已输入字符串
    let oldStr = this.previewTextList.map((value) => value.str).join('')
    Logger.info('旧的输入内容为:' + oldStr)
    let newStr: string = ''
    // 已使用的联想词列表
    let useWords = GlobalContext.getContext().getUseWords()
    useWords.forEach((value, index) => {
      showText.push(new PreviewText(value.showName, true))
    })

    let previewTextLockedState = getPreviewTextLockedState(this.inputContent)
    if (previewTextLockedState == PreviewTextLockedState.ALL_LOCKED) {

    } else if (previewTextLockedState == PreviewTextLockedState.PART_LOCKED) {

    } else {

    }

    // 获取第一个联想词的范围
    for (let i = 0; i < this.inputContent.length; i++) {
      let value = this.inputContent[i]
      let createWord = value.createWord
      if (createWord) {
        continue;
      }
      if (value.fillStr) {
        // 判断是否为手动选择的最后一个符号
        let isEnd = value.isEnd

        let nextStr = ''
        if (isEnd) {
          nextStr = value.selectStr == null ? '' : value.selectStr + "'"
        } else {
          // 智能选择下一个字符
          if (value.selectStr == null) {
            smartSelectChar(oldStr, value, pinyinStack)
          }
          nextStr = smartSetNextStrSeg(newStr, value.selectStr == null ? '' : value.selectStr)
        }
        // 判断是否为最后一个，最后一个字符不加分词符号
        if (i == this.inputContent.length - 1 && nextStr.endsWith("'")) {
          nextStr = nextStr.substring(0, nextStr.length - 1);
        }
        showText.push(new PreviewText(nextStr, value.locked))
        newStr += nextStr
      }

    }

    GlobalContext.getContext().setPreviewText(newStr)
    return { previewStr: newStr, previewTextArray: showText }
  }

  /**
   * 输入内容更新时调用事件
   */
  onInputUpdate() {
    if (this.inputContent.length == 0) {
      this.previewTextList = []
      this.suggestMode = false
      this.pinyinList.clearData()
      return
    }

    // 获取更新的拼音列表
    let pinyinGroup = this.changePinyinGroup()
    // 预输入文本更新
    let iPreviewText = this.getLoadShowInputContent(pinyinGroup)
    this.previewTextList = iPreviewText.previewTextArray
    // 滑动至最新输入的文本
    this.previewTextScroller.scrollEdge(Edge.End)
    let previewText = iPreviewText.previewStr
    // 预输入文本上仅剩候选词的情况
    if (previewText == "" && this.inputContent.length != 0 && GlobalContext.getContext().getUseWords().length > 0) {
      let useWords = GlobalContext.getContext().getUseWords()
      let wordAllStr = ''
      let pinyinAll = ''
      let keysAll: KeyButtonData[] = []
      useWords.forEach((useWord) => {
        wordAllStr += useWord.showName
        pinyinAll += useWord.previewText
        keysAll = keysAll.concat(useWord.keys)
      })

      this.suggestWords.replaceAllData(useWords)
      this.previewTextList = [new PreviewText(wordAllStr, true)]
      let allInOneWord = new SuggestionWord(wordAllStr, pinyinAll, keysAll)
      this.suggestWords.replaceAllData([allInOneWord])
    } else {
      // 更新联想词列表
      this.pageIndex = 1
      getAssociationWord(1, this.pageSize, previewText, this.inputContent, (suggestWords) => {
        let append: boolean = suggestWords.append
        Logger.info(`共查询到${suggestWords.words.length}个联想词`)

        this.suggestMode = suggestWords.words.length > 0 && !this.showPinYinListPage
        if (append) {
          this.suggestWords.appendAllData(suggestWords.words, true)
        } else {
          this.suggestWords.replaceAllData(suggestWords.words)
        }
      })
    }

    if (this.showPinYinListPage) {
      // 加载拼音列表界面数据
      this.loadPinyinPageInfoData()
    }
  }

  /**
   * 加载更多的数据
   */
  loadMoreData() {
    this.pageIndex++
    let previewText = GlobalContext.getContext().getPreviewText()
    getAssociationWord(this.pageIndex, this.pageSize, previewText, this.inputContent, (suggestWords) => {
      Logger.info(`分页数据加载中....共查询到${suggestWords.words.length}个联想词`)
      // this.suggestMode = suggestWords.words.length > 0 && !this.showPinYinListPage
      if (suggestWords.words.length > 0) {
        this.suggestWords.appendAllData(suggestWords.words, true)
      }
    })
  }

  /**
   * 改变拼音列表
   * @param previewText
   */
  private changePinyinGroup(): PinyinGroup[] {
    let pinyinGroup = getUpdatePinyinGroup(this.inputContent)
    // 更新左侧拼音列表
    this.pinyinList.replaceAllData(pinyinGroup)
    if (this.pinyinList.totalCount() == 0) {
      this.showPinYinListPage = false
    }
    return pinyinGroup
  }
}

/**
 * 预览文本
 */
export class PreviewText {
  id: string;
  // 显示内容
  str: string = ''
  // 是否已锁定
  lock: boolean = false;

  constructor(str: string, lock: boolean) {
    this.str = str
    this.lock = lock
    this.id = util.generateRandomUUID()
  }
}


/**
 * 键盘上方的工具栏
 */
@Component
@Preview
export struct InputToolBar {
  @State bgRes: Array<Resource> =
    [$r('app.media.app_center'), $r('app.media.keyboard_2'), $r('app.media.face'), $r('app.media.guangbiao_move'),
      $r('app.media.voice_2')]
  // 是否展示表情面板
  @Consume showEmojiPanel: boolean;

  build() {
    Row() {
      ForEach(this.bgRes, (item: Resource, index: number) => {
        Button() {
          Image(item).padding(index == 3 ? 8 : 5)
            .fillColor(Color.Black)
        }
        .width(40)
        .height(40)
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          if (index == 2) {
            this.showEmojiPanel = true;
          }
        })

      }, (item: Resource, index: number) => index + '')

    }
    .width('100%')
    .height(30)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.Transparent)
  }
}

/**
 * 联想词
 */
export class SuggestionWord {
  // 展示的名称
  showName: string = '';
  // 预输入文本(正在输入的框展示的字符串)
  previewText: string = ''
  // 按键组（表示由哪些的输入的按键构成)
  keys: Array<KeyButtonData> = []
  id: string = ''

  constructor(showName: string, previewText: string, keys: Array<KeyButtonData>) {
    this.showName = showName
    this.previewText = previewText
    this.keys = keys
    this.id = util.generateRandomUUID()
  }
}


/**
 * 获取联想词
 * @returns
 */
export async function getAssociationWord(pageIndex: number, pageSize: number, previewText: string,
  keyWord: KeyButtonData[], callback: (result: PinyinSuggestResult) => void) {
  if (keyWord.length == 0) {
    callback({ words: [], append: false })
  }
  let englishMode = isEnglishMode()
  spellToWord(pageIndex, pageSize, previewText, keyWord, englishMode, (result) => {
    callback(result)
  })
}


