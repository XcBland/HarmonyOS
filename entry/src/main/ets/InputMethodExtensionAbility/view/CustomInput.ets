import { inputMethod } from '@kit.IMEKit';

@Component
export struct CustomInput {
  @State inputText: string = '343434343'; // inputText作为Text组件要显示的内容。
  private inputController: inputMethod.InputMethodController = inputMethod.getController();

  build() {
    Row() {
      Text(this.inputText)// Text组件作为自绘编辑框的文本显示组件。
        .fontSize(16)
        .width('100%')
        .lineHeight(40)
        .id('customInput')
        .height(45)
        .border({ color: '#554455', radius: 30, width: 1 })
        .maxLines(1)
        .onClick(() => {
          this.attachAndListener(); // 点击控件
        })
    }.width('100%').backgroundColor(Color.Orange)

  }

  async attachAndListener() { // 绑定和设置监听
    focusControl.requestFocus('CustomInput');
    await this.inputController.attach(true, {
      inputAttribute: {
        textInputType: inputMethod.TextInputType.TEXT,
        enterKeyType: inputMethod.EnterKeyType.SEARCH
      }
    });
    this.inputController.on('insertText', (text) => {
      this.inputText += text;
    })
    this.inputController.on('deleteLeft', (length) => {
      this.inputText = this.inputText.substring(0, this.inputText.length - length);
    })
  }
}