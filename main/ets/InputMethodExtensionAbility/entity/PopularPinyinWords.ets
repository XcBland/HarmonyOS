import ArrayList from '@ohos.util.ArrayList';
import relationalStore from '@ohos.data.relationalStore';
import { ValuesBucket } from '@kit.ArkData';
import { KeyButtonData } from '../data/KeyButtonDataManager';
import { ColumnInfo } from './ColumnInfo';
import { objToNumber, objToString, toEntityList } from '../util/EntityUtil';

/**
 *
 * @TableName popular_pinyin_words
 */
export class PopularPinyinWords {
  /**
   *
   */
  wordId: number = 0;
  /**文本，非空，存储汉字词汇，例如 "你好"。
   *
   */
  word: string = '';
  /**
   * 本，非空，存储词汇的拼音，考虑到多音字，可以使用分隔符（如空格或逗号）区分不同的读音，例如 "ni hao"。
   */
  pinyin: string = '';
  /**
   * 布尔型或整型（1表示是，0表示否），可选，标记是否为常用词，有助于快速匹配。
   */
  isCommon: number = 0;
  /**
   * 整型，默认值为0，表示词汇的使用频率，数值越大表示越常用，可用于智能排序。
   */
  frequency: number = 0;
  /**
   * 词库id
   */
  repId: string = '';
  /**
   * 音调，为数字
   */
  tone: number = 0;
  /**
   * 词组完整拼音
   */
  groupPin: string = '';
  /**
   * 拼音九宫格对应的编码
   */
  nineGridKeyCode: string = ''
  /**
   * 原始拼音(带有分词符号)
   */
  originalPinyin: string = ''

  constructor(data: IPopularPinyinWords = {}) {
    if (data.wordId) {
      this.wordId = data.wordId;
    }
    if (data.word) {
      this.word = data.word;
    }
    if (data.pinyin) {
      this.pinyin = data.pinyin;
    }
    if (data.isCommon) {
      this.isCommon = data.isCommon;
    }
    if (data.frequency) {
      this.frequency = data.frequency;
    }
    if (data.repId) {
      this.repId = data.repId;
    }
    if (data.tone) {
      this.tone = data.tone;
    }
    if (data.groupPin) {
      this.groupPin = data.groupPin;
    }
    if (data.nineGridKeyCode) {
      this.nineGridKeyCode = data.nineGridKeyCode;
    }
    if (data.originalPinyin) {
      this.originalPinyin = data.originalPinyin;
    }
  }

  static getTableName(): string {
    return "POPULAR_PINYIN_WORDS";
  }

  static getColumnInfo(): ColumnInfo[] {
    return [new ColumnInfo("WORD_ID", "number"), new ColumnInfo("WORD", "string"), new ColumnInfo("PINYIN", "string"),
      new ColumnInfo("IS_COMMON", "number"), new ColumnInfo("FREQUENCY", "number"), new ColumnInfo("REP_ID", "string"),
      new ColumnInfo("TONE", "number"), new ColumnInfo("GROUP_PIN", "string"),
      new ColumnInfo("NINE_GRID_KEY_CODE", "string"), new ColumnInfo("ORIGINAL_PINYIN", "string")];
  }

  static mapToEntity(map: Map<string, string | number | Date | null>): PopularPinyinWords {
    let entity = new PopularPinyinWords();
    let wordId = objToNumber(map.get("WORD_ID"))
    entity.wordId = wordId;
    let word = objToString(map.get("WORD"))
    entity.word = word;
    let pinyin = objToString(map.get("PINYIN"))
    entity.pinyin = pinyin;
    let isCommon = objToNumber(map.get("IS_COMMON"))
    entity.isCommon = isCommon;
    let frequency = objToNumber(map.get("FREQUENCY"))
    entity.frequency = frequency;
    let repId = objToString(map.get("REP_ID"))
    entity.repId = repId;
    let tone = objToNumber(map.get("TONE"))
    entity.tone = tone;
    let groupPin = objToString(map.get("GROUP_PIN"))
    entity.groupPin = groupPin;
    let nineGridKeyCode = objToString(map.get("NINE_GRID_KEY_CODE"))
    entity.nineGridKeyCode = nineGridKeyCode;
    let originalPinyin = objToString(map.get("ORIGINAL_PINYIN"))
    entity.originalPinyin = originalPinyin;
    return entity;
  }

  static mapListToEntityList(mapList: Map<string, string | number | Date | null>[]): ArrayList<PopularPinyinWords> {
    let list = new ArrayList<PopularPinyinWords>()
    if (null == mapList || mapList == undefined) {
      return list
    }
    for (let map of mapList) {
      let entity = PopularPinyinWords.mapToEntity(map)
      list.add(entity)
    }
    return list;
  }

  static resultSetToList(resultSet: relationalStore.ResultSet): ArrayList<PopularPinyinWords> {
    let columnInfo = PopularPinyinWords.getColumnInfo()
    let mapList = toEntityList(columnInfo, resultSet)
    if (null == mapList || mapList == undefined) {
      return new ArrayList()
    }
    return PopularPinyinWords.mapListToEntityList(mapList)
  }

  static resultSetToOne(resultSet: relationalStore.ResultSet): PopularPinyinWords | null {
    let list = PopularPinyinWords.resultSetToList(resultSet)
    if (list.length > 0) {
      return list.removeByIndex(0);
    }
    return null
  }

  toJson(): ValuesBucket {
    return {
      WORD_ID: this.wordId ? this.wordId : null,
      WORD: this.word ? this.word : null,
      PINYIN: this.pinyin ? this.pinyin : null,
      IS_COMMON: this.isCommon ? this.isCommon : null,
      FREQUENCY: this.frequency ? this.frequency : null,
      REP_ID: this.repId ? this.repId : null,
      TONE: this.tone ? this.tone : null,
      GROUP_PIN: this.groupPin ? this.groupPin : null,
      NINE_GRID_KEY_CODE: this.nineGridKeyCode ? this.nineGridKeyCode : null,
      ORIGINAL_PINYIN: this.originalPinyin ? this.originalPinyin : null
    };
  }

  setWordId(wordId: number): void {
    this.wordId = wordId;
  }

  getWordId(): number {
    return this.wordId;
  }

  setWord(word: string): void {
    this.word = word;
  }

  getWord(): string {
    return this.word;
  }

  setPinyin(pinyin: string): void {
    this.pinyin = pinyin;
  }

  getPinyin(): string {
    return this.pinyin;
  }

  setIsCommon(isCommon: number): void {
    this.isCommon = isCommon;
  }

  getIsCommon(): number {
    return this.isCommon;
  }

  setFrequency(frequency: number): void {
    this.frequency = frequency;
  }

  getFrequency(): number {
    return this.frequency;
  }

  setRepId(repId: string): void {
    this.repId = repId;
  }

  getRepId(): string {
    return this.repId;
  }

  setTone(tone: number): void {
    this.tone = tone;
  }

  getTone(): number {
    return this.tone;
  }

  setGroupPin(groupPin: string): void {
    this.groupPin = groupPin;
  }

  getGroupPin(): string {
    return this.groupPin;
  }

  setNineGridKeyCode(nineGridKeyCode: string): void {
    this.nineGridKeyCode = nineGridKeyCode;
  }

  getNineGridKeyCode(): string {
    return this.nineGridKeyCode;
  }

  setOriginalPinyin(originalPinyin: string): void {
    this.originalPinyin = originalPinyin;
  }

  getOriginalPinyin(): string {
    return this.originalPinyin;
  }
}

interface IJsonPopularPinyinWords {
  WORD_ID: number;
  WORD: string;
  PINYIN: string;
  IS_COMMON: number;
  FREQUENCY: number;
  REP_ID: string;
  TONE: number;
  GROUP_PIN: string;
  NINE_GRID_KEY_CODE: string;
  ORIGINAL_PINYIN: string
}

export interface IPopularPinyinWords {
  wordId?: number | null;
  word?: string | null;
  pinyin?: string | null;
  isCommon?: number | null;
  frequency?: number | null;
  repId?: string | null;
  tone?: number | null;
  groupPin?: string | null;
  nineGridKeyCode?: string | null;
  originalPinyin?: string | null;
}
