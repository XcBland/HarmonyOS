import {
  getBottomButtonGroupData,
  getLeftButtonGroupData,
  getMainButtonGroupData,
  getNumberBottomButtonGroupData,
  getNumberLeftButtonGroupData,
  getNumberMainButtonGroupData,
  getNumberRightButtonGroupData,
  getRightButtonGroupData,
  KeyButtonData
} from '../data/KeyButtonDataManager';
import keyboardController from '../model/KeyboardController';
import { BusinessError } from '@kit.BasicServicesKit';
import { inputMethod } from '@kit.IMEKit';
import { switchChineseOrEnglish } from '../util/SwitchUtil';
import { PinyinDataSource, PinyinGroup } from '../dao/DataSouce';
import { CN_SUB_TYPE_ID } from '../constant/InputMethConstant';
import GlobalContext from '../context/GlobalContext';
import { getPreviewTextLockedState, PreviewTextLockedState } from '../util/SpellToWordUtil';
import Logger from '../util/Logger';


/**
 * 键盘
 */
@Component
@Preview
export struct MainInputPanel {
  @State mainKeyData: Array<KeyButtonData> = getMainButtonGroupData();
  @State leftKeyData: Array<KeyButtonData> = getLeftButtonGroupData();
  @State rightKeyData: Array<KeyButtonData> = getRightButtonGroupData();
  @State bottomKeyData: Array<KeyButtonData> = getBottomButtonGroupData();
  @State layoutOptions: GridLayoutOptions = {
    regularSize: [1, 1],
    onGetRectByIndex: (index: number) => {
      if (index == 0) { // key1是“0”按键对应的index
        return [0, 0, 3, 1]
      } else if (index == 1) { // key2是“=”按键对应的index
        return [0, 1, 1, 1]
      } else if (index == 2) {
        return [0, 2, 1, 1]
      } else if (index == 3) {
        return [0, 3, 1, 1]
      } else if (index == 4) {
        return [1, 1, 1, 1]
      } else if (index == 5) {
        return [1, 2, 1, 1]
      } else if (index == 6) {
        return [1, 3, 1, 1]
      } else if (index == 7) {
        return [2, 1, 1, 1]
      } else if (index == 8) {
        return [2, 2, 1, 1]
      } else if (index == 9) {
        return [2, 3, 1, 1]
      } else if (index == 10) {
        return [0, 4, 3, 1]
      } else if (index == 11) {
        return [3, 0, 1, 5]
      } else {
        return [3, 0, 5, 1]
      }
      // ...
      // 这里需要根据具体布局返回其他item的位置
    }
  }
  // @State inputContent:Array<KeyButtonData>  = []
  // @State @Watch("onNumberModeUpdate") numberMode:boolean = false;


  @Consume inputContent: Array<KeyButtonData>
  @Consume @Watch("onNumberModeUpdate") numberMode: boolean;
  @Consume pinyinList: PinyinDataSource;
  // 是否正在展示拼音列表界面
  @Consume showPinYinListPage: boolean;
  // 用于更新预览文本
  @Consume previewTextUpdate: boolean;
  // 之前锁定的按键
  beforePinyinGroupId: string = ''
  beforeLockedKey: Array<KeyButtonData> = []

  onNumberModeUpdate() {
    if (this.numberMode) {
      this.mainKeyData = getNumberMainButtonGroupData();
      this.leftKeyData = getNumberLeftButtonGroupData();
      this.rightKeyData = getNumberRightButtonGroupData();
      this.bottomKeyData = getNumberBottomButtonGroupData();
    } else {
      this.mainKeyData = getMainButtonGroupData();
      this.leftKeyData = getLeftButtonGroupData();
      this.rightKeyData = getRightButtonGroupData();
      this.bottomKeyData = getBottomButtonGroupData();
    }
    this.mainKeyData
  }

  build() {
    Row() {
      Grid(undefined, this.layoutOptions) {
        GridItem() {
          Column({ space: 3 }) {
            if (this.pinyinList.totalCount() > 0) {
              List({ space: 8 }) {
                LazyForEach(this.pinyinList, (item: PinyinGroup, index: number) => {
                  ListItem() {
                    Button() {
                      Text(item.name).fontSize(16).textAlign(TextAlign.Center)
                    }
                    .backgroundColor(Color.Transparent)
                    .type(ButtonType.Normal)
                    .width('100%')
                    .height(40)
                    .onClick(() => {
                      // 锁定正在查询的拼音为当前选择的字符
                      this.lockKeyButton(item)
                    })
                  }
                }, (item: PinyinGroup, index: number) => item.id)
              }.listDirection(Axis.Vertical).height('100%').layoutWeight(1)

            } else {
              ForEach(this.leftKeyData, (item: KeyButtonData, index: number) => {
                Button() {
                  Text(item.name).fontSize(16).textAlign(TextAlign.Center)
                }
                .backgroundColor(Color.Transparent)
                .type(ButtonType.Normal)
                .width('100%')
                .layoutWeight(1)
                .onClick(() => {
                  this.onButtonClick(item)
                })

              }, (item: KeyButtonData, index: number) => item.key)
            }


          }
          .width('100%')
          .height('100%')
          .backgroundColor('#dde1ec')
          .borderRadius(5)
          .justifyContent(FlexAlign.SpaceAround)

        }

        ForEach(this.mainKeyData, (item: KeyButtonData, index: number) => {
          GridItem() {
            Row() {
              Button() {
                Column({ space: 5 }) {
                  Text(item.upName).fontSize(10)
                  Text(item.name).fontSize(16)
                }
              }
              .backgroundColor(Color.White)
              .borderRadius(5)
              .type(ButtonType.Normal)
              .height('100%')
              .width('100%')
              .onClick(() => {
                this.onButtonClick(item)
              })
            }.width('100%').height('100%').padding(3).backgroundColor('#eff0f4')

          }.backgroundColor('#eff0f4')

        }, (item: KeyButtonData, index: number) => item.key)


        GridItem() {
          Column({ space: 4 }) {
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
                    Text(item.name).fontSize(14)
                  }
                }
                .backgroundColor('#dde3ec')
                .type(ButtonType.Normal)
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
        }

        // 最后一行工具行
        GridItem() {
          Row({ space: 5 }) {
            ForEach(this.bottomKeyData, (item: KeyButtonData, index: number) => {
              // 空格
              if (item.key == 'space') {
                Button() {
                  Image($r('app.media.space_2')).width(40).height(40)
                }
                .backgroundColor(this.numberMode ? '#dde1ec' : Color.White)
                .type(ButtonType.Normal)
                .borderRadius(5)
                .height('100%')
                .layoutWeight(this.numberMode ? 1 : 2.5)
                .onClick(() => {
                  this.onButtonClick(item)
                })

                // 回车
              } else if (item.key == 'enter') {
                Button() {
                  Image($r('app.media.enter')).width(40).height(40)
                    .padding(5)
                }
                .backgroundColor('#dde1ec')
                .type(ButtonType.Normal)
                .borderRadius(5)
                .height('100%')
                .layoutWeight(1)
                .onClick(() => {
                  this.onButtonClick(item)
                })
              } else {
                Button() {
                  if (item.key == 'chineseOrEnglish') {
                    Text() {
                      Span("中/").fontColor(Color.Black).fontSize(12)
                      Span("英").fontColor(Color.Grey).fontSize(10)
                    }
                  } else {
                    Text(item.name).fontSize(12)
                  }

                }
                .backgroundColor(this.numberMode && item.key == 'zero' ? Color.White : '#dde1ec')
                .type(ButtonType.Normal)
                .borderRadius(5)
                .height('100%')
                .layoutWeight(1)
                .onClick(() => {
                  this.onButtonClick(item)
                })
              }
            }, (item: KeyButtonData, index: number) => item.key)
          }.width('100%')
          .height('100%')
          .backgroundColor(Color.Transparent).justifyContent(FlexAlign.SpaceBetween)
        }.margin({ top: 2 })

      }
      .rowsGap(5)
      .columnsGap(1)
      .columnsTemplate('1fr 1.5fr 1.5fr 1.5fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr')
      .backgroundColor('#eff0f4')
    }.width('100%').layoutWeight(1).backgroundColor(Color.Transparent)
    .padding({
      left: 16,
      right: 16,
      top: 2,
      bottom: 4
    })
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
    }
  }

  /**
   * 按钮点击事件
   * @param item
   */
  onButtonClick(item: KeyButtonData) {
    if (item.key == 'chineseOrEnglish') {
      switchChineseOrEnglish()
    } else if (item.key == 'number') {
      this.numberMode = !this.numberMode
    } else if (item.key == 'back') {
      this.numberMode = false;
    } else if (item.key == 'zero' || item.key == 'space' || item.key == 'enter') {
      this.fillText(item)
    } else if (item.key == 'reInput') {
      let length = this.getShowInputContent().length
      keyboardController.clearText(length)
    } else if (item.key == 'del') {
      // 判断是否为锁定按钮，删除为解锁
      if (this.inputContent.length > 0) {
        // 判断最后一个按键是否为锁定状态
        let lastKey = this.inputContent[this.inputContent.length-1]
        if (lastKey.createWord) {
          GlobalContext.getContext().removeUseWord(lastKey)
          this.previewTextUpdate = !this.previewTextUpdate
        } else if (lastKey.locked) {
          // 解锁最后一组锁定的字符
          GlobalContext.getContext().unLastLockedKeys()
          // 通知预览文本更新
          this.previewTextUpdate = !this.previewTextUpdate
        } else {
          keyboardController.deleteForward(1);
          this.inputContent.pop()
        }
      } else {
        keyboardController.deleteForward(1);
      }


    } else {
      let inputMethodSubType = inputMethod.getCurrentInputMethodSubtype()
      // 中文输入展示预输入文本，英文输入暂时不展示联想词，直接输入
      if (null == inputMethodSubType || inputMethodSubType.id == CN_SUB_TYPE_ID) {
        this.pushToContent(item)
      } else {
        this.fillText(item)
      }
    }
  }

  /**
   * 点击按键之后的事件
   * @param inputData
   */
  pushToContent(inputData: KeyButtonData) {
    // 若为数字模式，直接输入，不需要查找词语
    if (this.numberMode) {
      if (inputData.fillStr) {
        keyboardController.insertText(inputData.fillStr)
      }
    } else {
      // 创建新的按键
      this.inputContent.push(inputData.copy())

      if (inputData.fillStr) {
        // 设置输入框里面的预上屏幕文本
        // let previewText = this.getShowInputContent()
        // keyboardController.setPreviewText(previewText)
      }
    }

  }

  /**
   * 填充文字
   * @param inputData
   */
  fillText(inputData: KeyButtonData) {
    if (inputData.fillStr) {
      keyboardController.insertText(inputData.fillStr)
    }
  }

  getShowInputContent(): string {
    let showText: string = ""
    this.inputContent.forEach((value, index) => {
      showText += value.name.charAt(0)
    })
    return showText
  }
}


