import { SuggestionWord } from '../view/SmartSuggestionBar';
import { getLongNineGridKeyCode } from './NineGridKeyCodeManager';

export class KeyButtonData {
  // 按钮上方小字
  upName: string = '';
  // 按钮显示名字
  name: string = ''
  // 按钮主键
  key: string = ''
  // 可输入的字符
  fillStr: string | null = null
  // 正在预输入对话框上展示的字符
  selectStr: string | null = null
  // 是否已被选中生成联想词
  createWord: boolean = false
  // 生成的联想词id
  createWordId: string = ''
  // 是否已锁定
  locked: boolean = false
  // 是否为最后一个字符(手动设置分词符号、选择拼音列表时最后一个按键为true)
  isEnd: boolean = false;

  constructor(upName: string, name: string, key: string, fillStr?: string | null | undefined) {
    this.upName = upName;
    this.name = name;
    this.key = key;
    if (fillStr) {
      this.fillStr = fillStr
    }
  }

  /**
   * 复制一个新对象
   * @returns
   */
  copy(): KeyButtonData {
    return new KeyButtonData(this.upName, this.name, this.key, this.fillStr)
  }
}

/**
 * 获取左侧按钮组
 * @returns
 */
export function getLeftButtonGroupData(): Array<KeyButtonData> {
  let array = new Array<KeyButtonData>();
  array.push(new KeyButtonData('', ',', ',', ","))
  array.push(new KeyButtonData('', '。', ' 。', '。'))
  array.push(new KeyButtonData('', '@', 'at', '@'))
  array.push(new KeyButtonData('', '?', '?', '？'))
  return array
}

/**
 * 获取拼音键盘中间的按钮组
 * @returns
 */
export function getMainButtonGroupData(): Array<KeyButtonData> {
  let array = new Array<KeyButtonData>();
  array.push(new KeyButtonData('1', '分词', 'split', '‘'))
  array.push(new KeyButtonData('2', 'ABC', 'abc', 'abc'))
  array.push(new KeyButtonData('3', 'DEF', 'def', 'def'))
  array.push(new KeyButtonData('4', 'GHI', 'ghi', 'ghi'))
  array.push(new KeyButtonData('5', 'JKL', 'jkl', 'ljk'))
  array.push(new KeyButtonData('6', 'MNO', 'mno', 'omn'))
  array.push(new KeyButtonData('7', 'PQRS', 'pqrs', 'spqr'))
  array.push(new KeyButtonData('8', 'TUV', 'tuv', 'tuv'))
  array.push(new KeyButtonData('9', 'WXYZ', 'wxyz', 'wxyz'))
  return array
}

/**
 * 获取右侧的按钮组
 * @returns
 */
export function getRightButtonGroupData(): Array<KeyButtonData> {
  let array = new Array<KeyButtonData>();
  array.push(new KeyButtonData('', '删除', 'del'))
  array.push(new KeyButtonData('', '重输', 'reInput'))
  array.push(new KeyButtonData('', '0', 'zero', '0'))
  return array
}

/**
 * 获取下方的按钮数据
 */
export function getBottomButtonGroupData(): Array<KeyButtonData> {
  let array = new Array<KeyButtonData>();
  array.push(new KeyButtonData('', '符', 'symbol'))
  array.push(new KeyButtonData('', '123', 'number'))
  array.push(new KeyButtonData('', '___', 'space', ' '))
  array.push(new KeyButtonData('', '中/英', 'chineseOrEnglish'))
  array.push(new KeyButtonData('', '_|', 'enter', '\n'))
  return array
}

/**
 * 数字键盘-主按钮区域数据
 * @returns
 */
export function getNumberMainButtonGroupData(): Array<KeyButtonData> {
  let array = new Array<KeyButtonData>();
  for (let index = 0; index < 9; index++) {
    let numberKey: string = (index + 1) + ''
    let keyButtonData = new KeyButtonData('', numberKey, numberKey, numberKey)
    array.push(keyButtonData)
  }
  return array
}


/**
 * 数字键盘-左侧按钮组
 * @returns
 */
export function getNumberLeftButtonGroupData(): Array<KeyButtonData> {
  let array = new Array<KeyButtonData>();
  let keys = ['%', "/", "-", "+"]
  keys.forEach((value: string, index: number) => {
    array.push(new KeyButtonData('', value, value, value))
  })
  return array
}

/**
 * 数字键盘-右侧的按钮组
 * @returns
 */
export function getNumberRightButtonGroupData(): Array<KeyButtonData> {
  let array = new Array<KeyButtonData>();
  array.push(new KeyButtonData('', '删除', 'del'))
  array.push(new KeyButtonData('', '.', 'point'))
  array.push(new KeyButtonData('', '@', 'at', '@'))
  return array
}

/**
 * 数字键盘-下方按钮数据
 */
export function getNumberBottomButtonGroupData(): Array<KeyButtonData> {
  let array = new Array<KeyButtonData>();
  array.push(new KeyButtonData('', '符', 'symbol'))
  array.push(new KeyButtonData('', '返回', 'back'))
  array.push(new KeyButtonData('', '0', 'zero', '0'))
  array.push(new KeyButtonData('', '___', 'space', ' '))
  array.push(new KeyButtonData('', '_|', 'enter', '\n'))
  return array
}

/**
 * 英文键盘第一行
 * @returns
 */
export function getEnglishFirstRowButtonGroupData(upperCase: number): Array<KeyButtonData> {
  let bottomChars = 'qwertyuiop';
  if (upperCase >= 1) {
    bottomChars = bottomChars.toUpperCase()
  }
  let length: number = bottomChars.length
  let array: Array<KeyButtonData> = []
  for (let index = 0; index < length; index++) {
    let charStr: string = bottomChars.charAt(index)
    let upName: string = (index + 1) + ''
    if (index == 9) {
      upName = '0'
    }
    let data: KeyButtonData = new KeyButtonData(upName, charStr, charStr, charStr)
    array.push(data)
  }
  return array
}

/**
 * 英文键盘第一行
 * @returns
 */
export function getEnglishSecondRowButtonGroupData(upperCase: number): Array<KeyButtonData> {
  let bottomChars = 'asdfghjkl';
  let upChars = '~!@#%\'&。?'
  if (upperCase >= 1) {
    bottomChars = bottomChars.toUpperCase()
  }
  let array: Array<KeyButtonData> = []
  for (let index = 0; index < bottomChars.length; index++) {
    let bottomChar = bottomChars[index]
    let upName = upChars[index]
    let data: KeyButtonData = new KeyButtonData(upName, bottomChar, bottomChar, bottomChar)
    array.push(data)
  }
  return array
}

/**
 * 英文键盘第三行
 * @returns
 */
export function getEnglishThirdRowButtonGroupData(upperCase: number): Array<KeyButtonData> {
  let bottomChars = 'zxcvbnm';
  if (upperCase >= 1) {
    bottomChars = bottomChars.toUpperCase()
  }

  let upChars = '()-_:;/'
  let array: Array<KeyButtonData> = []
  // 大写模式按钮
  array.push(new KeyButtonData('', '', 'upperCase'))
  for (let index = 0; index < bottomChars.length; index++) {
    let bottomChar = bottomChars[index]
    let upName = upChars[index]
    let data: KeyButtonData = new KeyButtonData(upName, bottomChar, bottomChar, bottomChar)
    array.push(data)
  }
  // 删除按钮
  array.push(new KeyButtonData('', '', 'del'))
  return array
}

/**
 *
 * 英文键盘-底部按钮
 * @returns
 */
export function getEnglishBottomButtonGroupData(): Array<KeyButtonData> {
  let array = new Array<KeyButtonData>();
  array.push(new KeyButtonData('', '!?#', 'symbol'))
  array.push(new KeyButtonData('', '123', 'number'))
  array.push(new KeyButtonData('', ',', 'comma', ','))
  array.push(new KeyButtonData('', '___', 'space'))
  array.push(new KeyButtonData('', '.', 'point', '.'))
  array.push(new KeyButtonData('', '中/英', 'chineseOrEnglish'))
  array.push(new KeyButtonData('', '_|', 'enter', '\n'))
  return array
}

/**
 * 获取拼音详情界面右侧的按钮组
 * @returns
 */
export function getPinyinDetailRightButtonGroupData(): Array<KeyButtonData> {
  let array = new Array<KeyButtonData>();
  array.push(new KeyButtonData('', '返回', 'back'))
  array.push(new KeyButtonData('', '删除', 'del'))
  array.push(new KeyButtonData('', '重输', 'reInput'))
  array.push(new KeyButtonData('', '拼/笔', 'pinyinOrWuBi'))
  array.push(new KeyButtonData('', '全/字', 'allOrWord'))
  return array
}

/**
 * 根据关键词纠正正在输入的显示字符
 * @param word
 */
export function correctKeyButtonDataSelectStr(word: SuggestionWord, keys: Array<KeyButtonData>) {
  if (!word) {
    return
  }
  // 联想词的九宫格编码
  let wordNineGridKeyCode = getLongNineGridKeyCode(word.keys)
  let keyNineGridKeyCode = getLongNineGridKeyCode(keys)
  let partOrAllMatch: boolean = wordNineGridKeyCode.startsWith(keyNineGridKeyCode)
  if (partOrAllMatch) {
    // 联想词的拼音
    let pinyin = word.previewText
    let pinyinArray = Array.from(pinyin)
    for (let i = 0; i < pinyin.length; i++) {
      let pinyinItem = pinyinArray[i]
      let key = keys[i]
      if (key != undefined && null != key.fillStr) {
        let containPinyinItem = key.fillStr.indexOf(pinyinItem) != -1
        if (containPinyinItem) {
          key.selectStr = pinyinItem
        }
      }
    }
  }


}