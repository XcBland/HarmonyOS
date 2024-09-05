import { Want } from '@kit.AbilityKit';
import keyboardController from './model/KeyboardController';
import { InputMethodExtensionAbility } from '@kit.IMEKit';
import GlobalContext from './context/GlobalContext';
import RdbManager from './dao/RdbManager';

export default class InputDemoService extends InputMethodExtensionAbility {
  onCreate(want: Want): void {
    keyboardController.onCreate(this.context); // 初始化窗口并注册对输入法框架的事件监听

    GlobalContext.getContext().setObject('mContext', this.context)
    // 初始化数据库
    RdbManager.initDb(this.context)
  }

  onDestroy(): void {
    console.log("onDestroy.");
    keyboardController.onDestroy(); // 销毁窗口并去注册事件监听
  }
}