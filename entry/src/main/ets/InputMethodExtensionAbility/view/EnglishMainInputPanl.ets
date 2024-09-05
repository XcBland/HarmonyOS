import {
  getBottomButtonGroupData,
  getEnglishBottomButtonGroupData,
  getEnglishFirstRowButtonGroupData,
  getEnglishSecondRowButtonGroupData,
  getEnglishThirdRowButtonGroupData,
  getLeftButtonGroupData,
  getMainButtonGroupData,
  getNumberMainButtonGroupData,
  getNumberRightButtonGroupData,
  getRightButtonGroupData,
  KeyButtonData
} from '../data/KeyButtonDataManager';
import keyboardController from '../model/KeyboardController';
import { switchChineseOrEnglish } from '../util/SwitchUtil';
import { NumberMainInputPanel } from './NumberMainInputPanl';

@Extend(Text)
function keyTextStyle() {
  .fontSize(26)
  .fontWeight(400)
}

/**
 * 键盘
 */
@Component
@Preview
export struct EnglishMainInputPanel {
  // 小写模式0 大小模式1 大写锁定模式2
  @State upperCaseMode: number = 0;
  @State firstKeyData: Array<KeyButtonData> = [];
  @State secondKeyData: Array<KeyButtonData> = [];
  @State thirdKeyData: Array<KeyButtonData> = [];
  @State bottomKeyData: Array<KeyButtonData> = [];
  // @State inputContent: Array<KeyButtonData> = []
  // @State numberMode: boolean = false;
  @Consume inputContent: Array<KeyButtonData>
  @Consume @Watch("onNumberModeUpdate") numberMode: boolean;
  keyHeight: number = 48;
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

  onNumberModeUpdate() {
    this.numberMode = this.numberMode
  }

  loadUIData() {
    this.firstKeyData = getEnglishFirstRowButtonGroupData(this.upperCaseMode);
    this.secondKeyData = getEnglishSecondRowButtonGroupData(this.upperCaseMode);
    this.thirdKeyData = getEnglishThirdRowButtonGroupData(this.upperCaseMode);
    this.bottomKeyData = getEnglishBottomButtonGroupData()
  }

  aboutToAppear(): void {
    this.loadUIData()
  }

  build() {
    if (this.numberMode) {
      NumberMainInputPanel()
    } else {
      Row() {
        Column({ space: 5 }) {
          Row({ space: 5 }) {
            ForEach(this.firstKeyData, (item: KeyButtonData, index: number) => {
              Button() {
                Column({ space: 5 }) {
                  Text(item.upName).fontSize(10)
                  Text(item.name).keyTextStyle()
                }
              }
              .backgroundColor(Color.White)
              .borderRadius(5)
              .type(ButtonType.Normal)
              .height('100%')
              .layoutWeight(1)
              .onClick(() => {
                this.pushToContent(item)
              })

            }, (item: KeyButtonData, index: number) => item.key)

          }.width('100%').height(this.keyHeight).justifyContent(FlexAlign.SpaceAround)

          Row({ space: 5 }) {
            ForEach(this.secondKeyData, (item: KeyButtonData, index: number) => {
              Row() {
                Button() {
                  Column({ space: 5 }) {
                    Text(item.upName).fontSize(10)
                    Text(item.name).keyTextStyle()
                  }
                }
                .backgroundColor(Color.White)
                .borderRadius(5)
                .type(ButtonType.Normal)
                .height('100%')
                .width('100%')
                .onClick(() => {
                  this.pushToContent(item)
                })
              }.layoutWeight(1).height(this.keyHeight).backgroundColor('#eff0f4')

            }, (item: KeyButtonData, index: number) => item.key)

          }.width('100%').height(this.keyHeight).justifyContent(FlexAlign.Center)
          .padding({ left: '5%', right: '5%' })

          Row({ space: 5 }) {
            ForEach(this.thirdKeyData, (item: KeyButtonData, index: number) => {
              if (item.key == 'del') {
                Button() {
                  Image($r('app.media.del')).width(40).height(40)
                    .padding(5)
                }
                .backgroundColor('#dde3ec')
                .type(ButtonType.Normal)
                .borderRadius(5)
                .height('100%')
                .layoutWeight(1.69)
                .onClick(() => {
                  keyboardController.deleteForward(1);
                  this.inputContent.pop()
                })
              } else if (item.key == 'upperCase') {
                Button() {
                  Image(this.upperCaseMode == 2 ? $r('app.media.upperCaseLock') :
                    this.upperCaseMode == 1 ? $r('app.media.upperCaseBlack') : $r('app.media.upperCase'))
                    .width(40).height(40)
                    .fillColor(Color.Black)
                    .padding(12)
                }
                .backgroundColor('#dde3ec')
                .borderRadius(5)
                .type(ButtonType.Normal)
                .width('100%')
                .layoutWeight(1.49)
                .onClick(() => {
                  // 转换为小写模式
                  if (this.upperCaseMode == 2) {
                    this.upperCaseMode = 0
                  } else {
                    // 大写模式
                    this.upperCaseMode = this.upperCaseMode + 1;
                    // 更新按钮的fillStr

                  }
                  // 更新界面
                  this.loadUIData()
                })
              } else {
                Button() {
                  Column({ space: 5 }) {
                    Text(item.upName).fontSize(10)
                    Text(item.name).keyTextStyle()
                  }
                }
                .backgroundColor(item.key == 'number' || item.key == 'chineseOrEnglish' ? '#dde3ec' : Color.White)
                .borderRadius(5)
                .type(ButtonType.Normal)
                .height('100%')
                .layoutWeight(1)
                .onClick(() => {
                  if (item.key == 'number') {
                    this.numberMode = true
                    // 切换子类型输入法为中文拼音
                    switchChineseOrEnglish()
                  } else {
                    this.pushToContent(item)
                  }

                })

              }

            }, (item: KeyButtonData, index: number) => item.key)
          }.width('100%').height(this.keyHeight).margin({ top: 2 })
          .justifyContent(FlexAlign.SpaceBetween)

          Row({ space: 5 }) {
            ForEach(this.bottomKeyData, (item: KeyButtonData, index: number) => {
              // 空格
              if (item.key == 'space') {
                Button() {
                  Image($r('app.media.space_2')).width(40).height(40)
                    .padding({ top: 15, bottom: 15 })
                }
                .backgroundColor(this.numberMode ? '#dde1ec' : Color.White)
                .type(ButtonType.Normal)
                .borderRadius(5)
                .height('100%')
                .layoutWeight(this.numberMode ? 1 : 2.5)

                // 回车
              } else if (item.key == 'enter') {
                Button() {
                  Image($r('app.media.enter')).width(40).height(40)
                    .fillColor(Color.Black)
                    .padding(5)
                }
                .backgroundColor('#dde1ec')
                .type(ButtonType.Normal)
                .borderRadius(5)
                .height('100%')
                .layoutWeight(1.6)
              } else {
                Button() {
                  if (item.key == 'chineseOrEnglish') {
                    Text() {
                      Span("中/").fontColor(Color.Grey).fontSize(10)
                      Span("英").fontColor(Color.Black).fontSize(12)
                    }
                  } else {
                    Text(item.name).fontSize(12)
                  }

                }
                .backgroundColor(item.key == 'comma' || item.key == 'point' ? Color.White : '#dde1ec')
                .type(ButtonType.Normal)
                .borderRadius(5)
                .height('100%')
                .layoutWeight(item.key == 'symbol' ? 1.6 : 1)
                .onClick(() => {
                  if (item.key == 'chineseOrEnglish') {
                    switchChineseOrEnglish()
                  } else if (item.key = 'number') {
                    this.numberMode = !this.numberMode
                  } else if (item.key == 'back') {
                    this.numberMode = false;
                  }
                })
              }

            }, (item: KeyButtonData, index: number) => item.key)
          }
          .width('100%')
          .height(this.keyHeight)
          .backgroundColor(Color.Transparent)
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%').height('100%')
        .backgroundColor(Color.Transparent)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#eff0f4')
      //.backgroundColor(Color.Orange)
      .alignItems(VerticalAlign.Center)
      .padding({
        left: 16,
        right: 16,
        top: 2,
        bottom: 4
      })
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
      let previewText = this.getShowInputContent()
      keyboardController.setPreviewText(previewText)
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

