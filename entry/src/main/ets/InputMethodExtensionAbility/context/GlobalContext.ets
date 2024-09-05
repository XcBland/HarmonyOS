/*
 * Copyright (C) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { relationalStore } from '@kit.ArkData';
import { KeyButtonData } from '../data/KeyButtonDataManager';
import { Queue, Stack } from '@kit.ArkTS';
import { SuggestionWord } from '../view/SmartSuggestionBar';

export default class GlobalContext {
  private static instance: GlobalContext;
  // 已选中的联想词
  useWords: Array<SuggestionWord> = []
  private objectMaps = new Map<string, Object>();
  private lockedKeys = new Stack<Array<KeyButtonData>>()

  private constructor() {
  }

  public static getContext(): GlobalContext {
    if (!GlobalContext.instance) {
      GlobalContext.instance = new GlobalContext();
    }
    return GlobalContext.instance;
  }

  getObject(value: string): Object {
    return this.objectMaps.get(value) as object;
  }

  setObject(key: string, objectClass: Object): void {
    this.objectMaps.set(key, objectClass);
  }

  getWordDb(): relationalStore.RdbStore {
    return this.objectMaps.get('wordsDb') as relationalStore.RdbStore
  }

  setWordDb(store: relationalStore.RdbStore) {
    this.setObject('wordsDb', store)
  }

  addLockedKeys(keys: Array<KeyButtonData>): void {
    // 自动加锁
    keys.forEach((key) => {
      key.locked = true
    })
    this.lockedKeys.push(keys)
  }

  /**
   * 解锁上次锁定的keys
   */
  unLastLockedKeys(): void {
    if (this.lockedKeys.length > 0) {
      this.lockedKeys.pop().forEach((key) => {
        key.locked = false
      })
    }

  }

  /**
   * 查看最后一个锁定的按键组
   * @returns
   */
  lockedKeyPeek(): KeyButtonData[] {
    return this.lockedKeys.peek()
  }

  setPreviewText(text: string): void {
    this.objectMaps.set('previewText', text)
  }

  getPreviewText(): string {
    if (this.objectMaps.has('previewText')) {
      return this.objectMaps.get('previewText') as string
    } else {
      return ''
    }
  }

  getUseWords(): Array<SuggestionWord> {
    return this.useWords
  }

  /**
   * 添加选中的联想词
   * @param word
   */
  addUseWords(word: SuggestionWord): void {
    this.useWords.push(word)
  }

  /**
   * 获取现使用的词的组合九宫格编码
   * @returns
   */
  getUseWordsNineGridKeyCode(): string {
    let nineGridKeyCode = ''
    this.useWords.forEach((word) => {
      nineGridKeyCode += word.keys.map(v => v?.upName).join('')
    })
    return nineGridKeyCode
  }

  clearUseWord(): void {
    this.useWords = []
  }

  /**
   * 删除该按键相关的word
   * @param key
   */
  removeUseWord(key: KeyButtonData) {
    if (key.createWord) {
      let createWordId = key.createWordId
      for (let i = 0; i < this.useWords.length; i++) {
        let value = this.useWords[i]
        for (let j = 0; j < value.keys.length; j++) {
          let key = value.keys[j]
          if (key.createWordId == createWordId) {
            value.keys.forEach((key) => {
              key.createWord = false
              key.createWordId = ''
            })
            // 删除该元素
            this.useWords.splice(i, 1)
            break
          }
        }


      }
    }
  }
}