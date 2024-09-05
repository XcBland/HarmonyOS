import ArrayList from '@ohos.util.ArrayList';
import relationalStore from '@ohos.data.relationalStore';
import { ValuesBucket } from '@kit.ArkData';
import { KeyButtonData } from '../data/KeyButtonDataManager';
import { ColumnInfo } from './ColumnInfo';
import { objToNumber, objToString, toEntityList } from '../util/EntityUtil';

/**
 *
 * @TableName emoji
 */
export class Emoji {
  /**
   *
   */
  id: number = 0;
  /**
   *
   */
  name: string = '';
  /**
   *
   */
  repId: number = 0;
  /**
   * 搜索关键词
   */
  keywords: string = '';
  /**
   * emoji表情字符
   */
  character: string = '';

  constructor(data: IEmoji = {}) {
    if (data.id) {
      this.id = data.id;
    }
    if (data.name) {
      this.name = data.name;
    }
    if (data.repId) {
      this.repId = data.repId;
    }
    if (data.keywords) {
      this.keywords = data.keywords;
    }
    if (data.character) {
      this.character = data.character;
    }
  }

  static getTableName(): string {
    return "EMOJI";
  }

  static getColumnInfo(): ColumnInfo[] {
    return [new ColumnInfo("_ID", "number"), new ColumnInfo("NAME", "string"), new ColumnInfo("REP_ID", "number"),
      new ColumnInfo("KEYWORDS", "string"), new ColumnInfo("CHARACTER", "string")];
  }

  static mapToEntity(map: Map<string, string | number | Date | null>): Emoji {
    let entity = new Emoji();
    let id = objToNumber(map.get("_ID"))
    entity.id = id;
    let name = objToString(map.get("NAME"))
    entity.name = name;
    let repId = objToNumber(map.get("REP_ID"))
    entity.repId = repId;
    let keywords = objToString(map.get("KEYWORDS"))
    entity.keywords = keywords;
    let character = objToString(map.get("CHARACTER"))
    entity.character = character;
    return entity;
  }

  static mapListToEntityList(mapList: Map<string, string | number | Date | null>[]): ArrayList<Emoji> {
    let list = new ArrayList<Emoji>()
    if (null == mapList || mapList == undefined) {
      return list
    }
    for (let map of mapList) {
      let entity = Emoji.mapToEntity(map)
      list.add(entity)
    }
    return list;
  }

  static resultSetToList(resultSet: relationalStore.ResultSet): ArrayList<Emoji> {
    let columnInfo = Emoji.getColumnInfo()
    let mapList = toEntityList(columnInfo, resultSet)
    if (null == mapList || mapList == undefined) {
      return new ArrayList()
    }
    return Emoji.mapListToEntityList(mapList)
  }

  static resultSetToOne(resultSet: relationalStore.ResultSet): Emoji | null {
    let list = Emoji.resultSetToList(resultSet)
    if (list.length > 0) {
      return list.removeByIndex(0);
    }
    return null
  }

  toJson(): ValuesBucket {
    return {
      _ID: this.id ? this.id : null,
      NAME: this.name ? this.name : null,
      REP_ID: this.repId ? this.repId : null,
      KEYWORDS: this.keywords ? this.keywords : null,
      CHARACTER: this.character ? this.character : null
    };
  }

  setId(id: number): void {
    this.id = id;
  }

  getId(): number {
    return this.id;
  }

  setName(name: string): void {
    this.name = name;
  }

  getName(): string {
    return this.name;
  }

  setRepId(repId: number): void {
    this.repId = repId;
  }

  getRepId(): number {
    return this.repId;
  }

  setKeywords(keywords: string): void {
    this.keywords = keywords;
  }

  getKeywords(): string {
    return this.keywords;
  }

  setCharacter(character: string): void {
    this.character = character;
  }

  getCharacter(): string {
    return this.character;
  }
}

interface IJsonEmoji {
  _ID: number;
  NAME: string;
  REP_ID: number;
  KEYWORDS: string;
  CHARACTER: string
}

export interface IEmoji {
  id?: number | null;
  name?: string | null;
  repId?: number | null;
  keywords?: string | null;
  character?: string | null;
}
