import { inputMethod } from '@kit.IMEKit'
import { US_SUB_TYPE_ID } from '../constant/InputMethConstant'

export function isEnglishMode() {
  let subType = inputMethod.getCurrentInputMethodSubtype()
  let englishMode = (null == subType || undefined == subType) ? false : subType.id == US_SUB_TYPE_ID
  return englishMode
}

