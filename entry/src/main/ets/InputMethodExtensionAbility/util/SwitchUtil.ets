/**
 * 切换中英文输入法
 */
import { inputMethod } from '@kit.IMEKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CN_SUB_TYPE_ID, US_SUB_TYPE_ID } from '../constant/InputMethConstant';

export function switchChineseOrEnglish() {
  const currentSubtype = inputMethod.getCurrentInputMethodSubtype();
  let isCnInput = null == currentSubtype || currentSubtype.id == CN_SUB_TYPE_ID
  if (isCnInput) {
    switchInputSubtype(US_SUB_TYPE_ID)
  } else {
    switchInputSubtype(CN_SUB_TYPE_ID)
  }

}

export function switchInputSubtype(subTypeId: string) {
  try {
    let extra: Record<string, string> = {}
    let isCnInput = subTypeId == CN_SUB_TYPE_ID
    inputMethod.switchCurrentInputMethodSubtype({
      id: isCnInput ? CN_SUB_TYPE_ID : US_SUB_TYPE_ID,
      mode: "upper",
      locale: isCnInput ? "zh-CN" : "en-US",
      name: 'com.lonwan.input.method',
      language: isCnInput ? "zh-CN" : "en-US"
    }, (err: BusinessError, result: boolean) => {
      if (err) {
        console.error(`Failed to switchCurrentInputMethodSubtype: ${JSON.stringify(err)}`);
        return;
      }
      if (result) {
        console.log('Succeeded in switching currentInputMethodSubtype.');
      } else {
        console.error('Failed to switchCurrentInputMethodSubtype');
      }
    });
  } catch (err) {
    console.error(`Failed to switchCurrentInputMethodSubtype: ${JSON.stringify(err)}`);
  }
}