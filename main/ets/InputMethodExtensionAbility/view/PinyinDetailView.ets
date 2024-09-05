import { PinyinDataSource, PinyinGroup, WordSuggestDataSource } from '../dao/DataSouce';
import { getAssociationWord, SuggestionWord } from './SmartSuggestionBar';
import { util } from '@kit.ArkTS';
import {
  convert2SuggestWord,
  extractChineseCharacters,
  getDictInfo,
  getPreviewTextLockedState,
  getSpellDictJian,
  getUpdatePinyinGroup,
  isFullPinyin,
  PreviewTextLockedState
} from '../util/SpellToWordUtil';
import { getPinyinDetailRightButtonGroupData, KeyButtonData } from '../data/KeyButtonDataManager';
import { switchChineseOrEnglish } from '../util/SwitchUtil';
import { inputMethod } from '@kit.IMEKit';
import keyboardController from '../model/KeyboardController';
import { MockSetup } from '@ohos/hamock';
import WordService from '../dao/WordsService';
import { getLongNineGridKeyCode } from '../data/NineGridKeyCodeManager';
import Logger from '../util/Logger';
import GlobalContext from '../context/GlobalContext';

@Component
@Preview
  // @Entry
export struct PinyinDetailView {
  //
  @Consume @Watch("onPinyinListUpdate") pinyinList: PinyinDataSource;
  // @State wordsDataSource: Array<PinyinSuggestGroup> = [];
  // @State wordsDataSource: WordDataSource = this.getTestData();

  // 当前的拼音index
  @State currentWordsIndex: number = 0
  @State rightKeyData: KeyButtonData[] = getPinyinDetailRightButtonGroupData()
  // @State pinyinList:Array<string> = ['ai', 'bi', 'ci', 'ch', "ci", 'a', 'b', 'c']

  // 是否正在展示拼音列表界面
  @Consume showPinYinListPage: boolean;
  //
  @Consume inputContent: Array<KeyButtonData>
  // 当前界面展示的拼音对应的联想词
  @Consume pageWords: WordSuggestDataSource
  @Consume
  // @Watch("onInputUpdate")
  previewTextUpdate: boolean;
  scroller: Scroller = new Scroller()
  pageIndex: number = 1;
  pageSize: number = 100;

  @MockSetup
  mock() {
    // this.wordsDataSource = this.getTestData();
    // this.currentWords = this.wordsDataSource[0].words
  }

  onPinyinListUpdate() {
    if (this.pinyinList.totalCount() > 0) {
      // WordService.queryByKeyword(this.pinyinList.getData(0).name, (suggestWords)=>{
      //   let keyMap = this.pinyinList.getPinYinKeyMap()
      //   this.pageWords.replaceAllData(convert2SuggestWord(keyMap, suggestWords));
      // })
    }
  }

  getTestData(): Array<PinyinGroup> {
    let pinyinGroup: Array<PinyinGroup> = []
    let pinyinList = ['ai', 'bi', 'ci', 'ch']
    let spellDictJian = getSpellDictJian()
    let initialData = getDictInfo();
    let index: number = 0
    pinyinList.forEach((value) => {
      // 检查是否为声母
      if (initialData.initial.includes(value)) {
        const hanzhiList: string = '艾9哎1哀1诶1唉9唉6埃1挨7挨6爱4砹4捱2皑2隘4嗌9嗳9嗳8嗳6嫒4矮3碍4暧4瑷4蔼3锿1噫9癌2霭3娭6'
        if (hanzhiList && hanzhiList.length > 0) {
          let chineseCharacters: Array<SuggestionWord> = extractChineseCharacters(value, hanzhiList, [])
          //
          chineseCharacters.forEach((item) => {
            item.id = index + ''
            index += 1
          })

          let group: PinyinGroup = new PinyinGroup(value, util.generateRandomUUID(), [])
          pinyinGroup.push(group)
        }
      }
    })
    return pinyinGroup;
  }

  build() {
    Row() {
      // 左侧菜单栏
      Row() {
        List({ space: 1 }) {
          LazyForEach(this.pinyinList, (item: PinyinGroup, index: number) => {
            ListItem() {
              Button() {
                Text(item.name)
                  .textAlign(TextAlign.Center)
                  .height(40)
                  .width('100%')
              }
              .type(ButtonType.Normal)
              .backgroundColor(Color.Transparent)
              .backgroundColor(Color.White)
              .width('100%')
              .onClick(() => {
                // 锁定正在查询的拼音为当前选择的字符
                this.lockKeyButton(item)
                this.currentWordsIndex = index

              })
            }
          }, (item: PinyinGroup) => item.id)
        }.width('100%').height('100%').alignListItem(ListItemAlign.Center)
      }.width('13%').height('100%').backgroundColor(Color.White)

      Row()
        .backgroundColor('#f1f1f1')
        .opacity(0.5)
        .width(0.5).height('100%')

      // 右侧具体拼音栏
      Row() {
        Grid(this.scroller) {
          LazyForEach(this.pageWords, (item: SuggestionWord) => {
            GridItem() {
              Button() {
                Text(item.showName)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .height(40)
              }
              .backgroundColor(Color.White)
              .layoutWeight(1)
              .borderColor('#f1f1f1')
              .borderWidth({ bottom: 0.01 })
              .type(ButtonType.Normal)
              .onClick(() => {
                this.onSuggestWordClick(item)
              })
            }
          }, (item: SuggestionWord) => item.id)
        }.columnsTemplate('1fr 1fr 1fr 1fr')
        //.friction(0.6)
        .width('100%')
        .height('100%')
        .onReachEnd(() => {
          this.loadMoreData()
        })

        // .rowsGap(0.2)
      }
      .layoutWeight(1)
      .height('100%')
      .borderRadius(5)
      .backgroundColor(Color.Transparent)
      .margin({ right: 5 })

      // 右侧按钮栏
      Row() {
        Column({ space: 6 }) {
          ForEach(this.rightKeyData, (item: KeyButtonData, index: number) => {
            if (item.key == 'del') {
              Button() {
                Image($r('app.media.del')).width(40).height(40)
                  .padding(5)
              }
              .backgroundColor('#dde3ec')
              .type(ButtonType.Normal)
              .width('100%')
              .layoutWeight(1)
              .onClick(() => {
                this.onButtonClick(item)
              })
            } else if (item.key == 'zero') {
              Button() {
                Column() {
                  Text(item.name).fontSize(18)
                }
              }
              .backgroundColor('#dde3ec')
              .type(ButtonType.Normal)
              .borderRadius(5)
              .width('100%')
              .layoutWeight(1)
              .onClick(() => {
                this.onButtonClick(item)
              })
            } else {
              Button() {
                Column() {
                  if (item.key == 'allOrWord') {
                    Text() {
                      Span('全').fontSize(14)
                      Span('/字').fontSize(12).fontColor(Color.Grey)
                    }
                  } else if (item.key == 'pinyinOrWuBi') {
                    Text() {
                      Span('拼').fontSize(14)
                      Span('/笔').fontSize(12).fontColor(Color.Grey)
                    }
                  } else {
                    Text(item.name).fontSize(14)
                  }

                }
              }
              .backgroundColor('#dde3ec')
              .type(ButtonType.Normal)
              .borderRadius(5)
              .width('100%')
              .layoutWeight(1)
              .onClick(() => {
                this.onButtonClick(item)
              })
            }


          }, (item: KeyButtonData, index: number) => item.key)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#eff0f4')
        .borderRadius(5)
        .justifyContent(FlexAlign.SpaceAround)
      }.width('15%').height('100%').backgroundColor(Color.Transparent)

    }.width('100%')
    .layoutWeight(1)
    .backgroundColor(Color.Transparent)
    .padding({
      left: 16,
      right: 16,
      top: 2,
      bottom: 4
    })
  }

  /**
   * 候选词点击事件
   * @param word
   */
  onSuggestWordClick(word: SuggestionWord) {

    // 清空联想词相关按键
    word.keys.forEach((value, index) => {
      if (value) {
        value.createWord = true
        value.createWordId = word.id
      }
    })
    // 完成拼写，更新按键状态
    let context = GlobalContext.getContext()
    context.addUseWords(word)

    // 判断本次输入是否已完成
    let suggestNineGridCode = context.getUseWordsNineGridKeyCode()
    let previewTextNineGridCode = getLongNineGridKeyCode(this.inputContent)
    let completeInput: boolean = suggestNineGridCode.length >= previewTextNineGridCode.length
    // && previewTextNineGridCode.startsWith(suggestNineGridCode);

    // 输入完成，清空已输入按钮
    if (completeInput) {
      this.inputContent = []
      GlobalContext.getContext().clearUseWord()
      // 添加文字进入输入框
      keyboardController.insertText(word.showName);
      // 返回九宫格按键界面
      this.showPinYinListPage = false;
      this.changePinyinGroup()
    }
    Logger.info(`当前联想词的九宫格编码为: ${suggestNineGridCode},  预览文本的九宫格编码为: ${previewTextNineGridCode}, 完成一次输入:${completeInput}`)
    this.previewTextUpdate = !this.previewTextUpdate
  }

  /**
   * 按钮点击事件
   * @param item
   */
  onButtonClick(item: KeyButtonData) {
    if (item.key == 'chineseOrEnglish') {
      switchChineseOrEnglish()
    } else if (item.key == 'back') {
      this.showPinYinListPage = false;
    } else if (item.key == 'reInput') {
      // let length = this.getShowInputContent().length
      // keyboardController.clearText(length)
    } else if (item.key == 'del') {
      keyboardController.deleteForward(1);
      this.inputContent.pop()
    } else {
    }
  }

  /**
   * 点击按键之后的事件
   * @param inputData
   */
  pushToContent(inputData: KeyButtonData) {
    this.inputContent.push(inputData)
    if (inputData.fillStr) {
      // 设置输入框里面的预上屏幕文本
      // let previewText = this.getShowInputContent()
      // keyboardController.setPreviewText(previewText)
    }
  }

  /**
   * 锁定正在输入的字符
   */
  lockKeyButton(pinyin: PinyinGroup) {
    if (pinyin) {
      // 相等则代表，还是和上一次同一个pinyinGroup 还原之前选中的字符
      let previewTextLockedState = getPreviewTextLockedState(this.inputContent)
      if (previewTextLockedState == PreviewTextLockedState.ALL_LOCKED) {
        let peekValue = GlobalContext.getContext().lockedKeyPeek();
        if (peekValue != undefined) {
          peekValue.forEach((beforeKey) => {
            beforeKey.locked = false
            beforeKey.isEnd = false
          })
        }
      }

      let keys = pinyin.keys
      let pinyinStr = pinyin.name
      let pinyinArray = Array.from(pinyinStr)
      for (let i = 0; i < pinyinArray.length; i++) {
        let key = keys[i]
        if (key) {
          key.locked = true
          key.isEnd = false
          key.selectStr = pinyinArray[i]
          // 末位字符加分词符号
          if (i == pinyinArray.length - 1) {
            key.isEnd = true
          }
        } else {
          Logger.error('key 异常！' + JSON.stringify(key))
        }

      }
      // 添加进全局字符锁队列
      GlobalContext.getContext().addLockedKeys(keys)
      // 重新加载上方的预输入文本
      this.previewTextUpdate = !this.previewTextUpdate
      // 重新加载右侧的拼音Grid
      let previewText = GlobalContext.getContext().getPreviewText()
      this.changePinyinGroup()
      this.pageIndex = 1
      // 更新联想词列表
      getAssociationWord(1, this.pageSize, previewText, this.inputContent, (suggestWords) => {
        let append: boolean = suggestWords.append
        Logger.info(`共查询到${suggestWords.words.length}个联想词`)

        if (append) {
          this.pageWords.appendAllData(suggestWords.words, true)
        } else {
          this.pageWords.replaceAllData(suggestWords.words)
        }

      })
      // 跳转至Grid开始位置
      this.scroller.scrollEdge(Edge.Start)
    }
  }

  /**
   * 到达底部时加载更多数据
   */
  loadMoreData() {
    // 更新联想词列表
    this.pageIndex++
    // 重新加载右侧的拼音Grid
    let previewText = GlobalContext.getContext().getPreviewText()
    getAssociationWord(this.pageIndex, this.pageSize, previewText, this.inputContent, (suggestWords) => {
      let append: boolean = suggestWords.append
      Logger.info(`正在加载下一页数据，共查询到${suggestWords.words.length}个联想词`)
      if (suggestWords.words.length > 0) {
        this.pageWords.appendAllData(suggestWords.words, true)
      }

    })

  }

  /**
   * 改变拼音列表
   * @param previewText
   */
  private changePinyinGroup() {
    let pinyinGroup = getUpdatePinyinGroup(this.inputContent)
    // 更新左侧拼音列表
    this.pinyinList.replaceAllData(pinyinGroup)
    if (this.pinyinList.totalCount() == 0) {
      this.showPinYinListPage = false
    }
  }
}


