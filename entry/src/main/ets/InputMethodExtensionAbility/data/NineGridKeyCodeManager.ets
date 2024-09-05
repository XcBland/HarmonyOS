import { HashMap, Queue } from '@kit.ArkTS';
import { PinyinGroup } from '../dao/DataSouce';
import { KeyButtonData } from './KeyButtonDataManager';

export class NineGridKeyCodeData {
  nineGridKeyCode: string = '';
  relationKeys: Queue<KeyButtonData> = new Queue()
}

export function getKeyMapFromKeyButtonData(keys: Array<KeyButtonData>): HashMap<string, NineGridKeyCodeData> {
  let map = new HashMap<string, NineGridKeyCodeData>();
  // 过滤已被选中的候选词key
  keys = keys.filter(v =>!v.createWord)
  keys.forEach((btnKey) => {
    let nineGridKeyCode = btnKey.upName
    if (map.hasKey(nineGridKeyCode)) {
      map.get(nineGridKeyCode).relationKeys.add(btnKey)
    } else {
      let nineGridKeyCodeMap = new NineGridKeyCodeData()
      nineGridKeyCodeMap.nineGridKeyCode = nineGridKeyCode
      nineGridKeyCodeMap.relationKeys.add(btnKey)
      map.set(nineGridKeyCode, nineGridKeyCodeMap)
    }
  })
  return map;
}

export function getKeyMapFromPinyinGroup(pinyinGroup: Array<PinyinGroup>): HashMap<string, NineGridKeyCodeData> {
  let keyMap: HashMap<string, NineGridKeyCodeData> = new HashMap<string, NineGridKeyCodeData>();
  pinyinGroup.forEach((pinyinG) => {
    pinyinG.keys.forEach((key) => {
      if (key) {
        let nineGridCode = key.upName
        if (keyMap.hasKey(nineGridCode)) {
          keyMap.get(nineGridCode).relationKeys.add(key)
        } else {
          let nineGridKeyCodeData = new NineGridKeyCodeData()
          nineGridKeyCodeData.nineGridKeyCode = nineGridCode
          nineGridKeyCodeData.relationKeys.add(key)
          keyMap.set(nineGridCode, nineGridKeyCodeData);
        }
      }


    })
  })
  return keyMap
}


/**
 * 获取
 * @param nineGridKeyCode
 * @param map
 * @returns
 */
export function getKeysFromLongNineGridKeyCode(nineGridKeyCode: string,
  map: HashMap<string, NineGridKeyCodeData>): KeyButtonData[] {
  let keys = new Array<KeyButtonData>()
  let array = Array.from(nineGridKeyCode)
  array.forEach((value) => {
    let keyData = map.get(value)
    if (keyData) {
      keys.push(keyData.relationKeys.pop())
    }
  })
  return keys
}

/**
 * 获取按键组的九宫格编码
 * @param keys
 * @returns
 */
export function getLongNineGridKeyCode(keys: Array<KeyButtonData>): string {
  let nineGridKeyCode = keys.filter((v) => v != undefined && v != null).map((v) => v.upName).join('')
  return nineGridKeyCode;
}