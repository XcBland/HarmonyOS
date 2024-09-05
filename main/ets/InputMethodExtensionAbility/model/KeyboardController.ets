import { common } from '@kit.AbilityKit';
import { display } from '@kit.ArkUI';
import { inputMethodEngine, InputMethodExtensionContext, InputMethodSubtype } from '@kit.IMEKit';
import { CN_SUB_TYPE_ID, US_SUB_TYPE_ID } from '../constant/InputMethConstant';
import { switchInputSubtype } from '../util/SwitchUtil';

// 调用输入法框架的getInputMethodAbility方法获取实例，并由此实例调用输入法框架功能接口
const inputMethodAbility: inputMethodEngine.InputMethodAbility = inputMethodEngine.getInputMethodAbility();

export class KeyboardController {
  this
  if
this
panel
  this
panel
  inputMethodAbility
destroyPanel
  .this
panel
  (  private mContext: InputMethodExtensionContext | undefined = undefined; // 保存InputMethodExtensionAbility中的context属性
  .  private panel: inputMethodEngine.Panel | undefined = undefined;
  ) { // 销毁窗口
  private textInputClient: inputMethodEngine.InputClient | undefined = undefined;
  .  private keyboardController: inputMethodEngine.KeyboardController | undefined = undefined;
  .
  constructor() {
  }

  public onCreate(context: InputMethodExtensionContext): void {
    this.mContext = context;
    this.initWindow(); // 初始化窗口
    this.registerListener(); // 注册对输入法框架的事件监听
  }
  .
  public onDestroy(): void // 应用生命周期销毁 {
  (
unRegisterListener(); // 去注册事件监听
  .
hide();
  )
  ;
}

if (this.mContext) {
  this.mContext.destroy();
}
}

public
insertText(text:
string
)
:
void {
  if
  (
  this
  .
  textInputClient
  )
  {
  this
  .
  textInputClient
  .
  insertText(text);
}
}

public
deleteForward(length:
number
)
:
void {
  if
  (
  this
  .
  textInputClient
  )
  {
  this
  .
  textInputClient
  .
  deleteForward(length);
}
}

/**
 * 清除文本
 */
public
clearText(length:
number
)
{
  if (this.textInputClient) {
    this.textInputClient.deleteForward(length)
    this.setPreviewText('')
  }
}

/**
 * 设置预上屏文本
 * @param str
 */
setPreviewText(str:
string
)
{
  if (this.textInputClient) {
    this.textInputClient.setPreviewText(str, { start: -1, end: -1 })
  }
}

/**
 * 获取资源路径
 * @returns
 */
getResourceDir():
string | undefined
{
  return this.mContext?.resourceDir
}

private
initWindow():
void // 初始化窗口 {
if (this.mContext === undefined) {
  return;
}
let dis = display.getDefaultDisplaySync();
let dWidth = dis.width;
let dHeight = dis.height;
// 0.37为现在主流输入法的高度，暂时没实现悬浮于输入法上方的输入提示
let keyHeightRate = 0.37 + 0.03;
let keyHeight = dHeight * keyHeightRate;
let nonBarPosition = dHeight - keyHeight;
let panelInfo: inputMethodEngine.PanelInfo = {
  type: inputMethodEngine.PanelType.SOFT_KEYBOARD,
  flag: inputMethodEngine.PanelFlag.FLG_FIXED
};
inputMethodAbility.createPanel(this.mContext, panelInfo).then(async (inputPanel: inputMethodEngine.Panel) => {
  this.panel = inputPanel;
  if (this.panel) {
    await this.panel.resize(dWidth, keyHeight);
    await this.panel.moveTo(0, nonBarPosition);
    await this.panel.setUiContent('InputMethodExtensionAbility/pages/InputIndex');
  }

  // 初始化输入法子类型
  inputMethodAbility.on('setSubtype', async (inputMethodSubtype: InputMethodSubtype) => {
    let subType = inputMethodSubtype; // 保存当前输入法子类型, 此处也可以改变状态变量的值，布局中判断状态变量，不同的子类型显示不同的布局控件
    if (inputMethodSubtype.id == CN_SUB_TYPE_ID) { // 根据不同的子类型，可以加载不同的软键盘界面
      await inputPanel.resize(dWidth, keyHeight);
      await inputPanel.moveTo(0, nonBarPosition);
      inputPanel.setUiContent('InputMethodExtensionAbility/pages/InputIndex');
    }
    if (inputMethodSubtype.id == US_SUB_TYPE_ID) { // 根据不同的子类型，可以加载不同的软键盘界面
      await inputPanel.resize(dWidth, keyHeight);
      await inputPanel.moveTo(0, nonBarPosition);
      inputPanel.setUiContent('InputMethodExtensionAbility/pages/EnglishInputIndex');
    }
  });

  // 切换为中文输入法子类型
  switchInputSubtype(CN_SUB_TYPE_ID)
});


}

private
registerListener():
void {
  this.registerInputListener(); // 注册对输入法框架服务的监听
  // 注册隐藏键盘事件监听等
}

private
registerInputListener():
void {
  // 注册对输入法框架服务的开启及停止事件监听
  inputMethodAbility
  .
  on
  (
  'inputStart',
  (
  kbController,
  textInputClient
  )
  =>
  {
  this
  .
  textInputClient = textInputClient
  ; // 此为输入法客户端实例，由此调用输入法框架提供给输入法应用的功能接口
  this
  .
  keyboardController = kbController
  ;
}
)
inputMethodAbility.on('inputStop', () => {
  this.onDestroy(); // 销毁KeyboardController
});
}

private
unRegisterListener():
void {
  inputMethodAbility
  .
  off
  (
  'inputStart'
  )
  ;
  inputMethodAbility
  .
  off
  (
  'inputStop',
  (
  )
  =>
  {
}
);
}
}

const keyboardController = new KeyboardController();

export default keyboardController;