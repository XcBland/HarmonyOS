import {
  getNumberBottomButtonGroupData,
  getNumberLeftButtonGroupData,
  getNumberMainButtonGroupData,
  getNumberRightButtonGroupData,
  KeyButtonData
} from '../data/KeyButtonDataManager';
import keyboardController from '../model/KeyboardController';
import { BusinessError } from '@kit.BasicServicesKit';
import { inputMethod } from '@kit.IMEKit';
import { switchChineseOrEnglish } from '../util/SwitchUtil';
import { CN_SUB_TYPE_ID } from '../constant/InputMethConstant';

/**
 * 键盘
 */
@Component
@Preview
export struct NumberMainInputPanel {
  @State mainKeyData: Array<KeyButtonData> = getNumberMainButtonGroupData();
  @State leftKeyData: Array<KeyButtonData> = getNumberLeftButtonGroupData();
  @State rightKeyData: Array<KeyButtonData> = getNumberRightButtonGroupData();
  @State bottomKeyData: Array<KeyButtonData> = getNumberBottomButtonGroupData();
  // @State inputContent:Array<KeyButtonData> = []
  // @State numberMode:boolean = false;

  @Consume inputContent: Array<KeyButtonData>
  @Consume numberMode: boolean;
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

  build() {
    Row() {
      Grid(undefined, this.layoutOptions) {
        GridItem() {
          Column({ space: 3 }) {
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
                  this.fillText(item)
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
                  Image($r('app.media.space')).width(40).height(40)
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
      keyboardController.deleteForward(1);
      this.inputContent.pop()
    } else {
      let inputMethodSubType = inputMethod.getCurrentInputMethodSubtype()
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
    if (this.numberMode) {
      if (inputData.fillStr) {
        keyboardController.insertText(inputData.fillStr)
      }
    } else {
      this.inputContent.push(inputData)
      if (inputData.fillStr) {
        // 设置输入框里面的预上屏幕文本
        let previewText = this.getShowInputContent()
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


