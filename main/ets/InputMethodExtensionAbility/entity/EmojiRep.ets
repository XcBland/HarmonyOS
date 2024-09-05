import ArrayList from '@ohos.util.ArrayList';
import relationalStore from '@ohos.data.relationalStore';
import { ValuesBucket } from '@kit.ArkData';
import { KeyButtonData } from '../data/KeyButtonDataManager';
import { ColumnInfo } from './ColumnInfo';
import { objToNumber, objToString, toEntityList } from '../util/EntityUtil';

/**
 *
 * @TableName emoji_rep
 */
export class EmojiRep {
  /**
   *
   */
  id: number = 0;
  /**
   *
   */
  name: string = '';

  constructor(data: IEmojiRep = {}) {
    if (data.id) {
      this.id = data.id;
    }
    if (data.name) {
      this.name = data.name;
    }
  }

  static getTableName(): string {
    return "EMOJI_REP";
  }

  static getColumnInfo(): ColumnInfo[] {
    return [new ColumnInfo("_ID", "number"), new ColumnInfo("NAME", "string")];
  }

  static mapToEntity(map: Map<string, string | number | Date | null>): EmojiRep {
    let entity = new EmojiRep();
    let id = objToNumber(map.get("_ID"))
    entity.id = id;
    let name = objToString(map.get("NAME"))
    entity.name = name;
    return entity;
  }

  static mapListToEntityList(mapList: Map<string, string | number | Date | null>[]): ArrayList<EmojiRep> {
    let list = new ArrayList<EmojiRep>()
    if (null == mapList || mapList == undefined) {
      return list
    }
    for (let map of mapList) {
      let entity = EmojiRep.mapToEntity(map)
      list.add(entity)
    }
    return list;
  }

  static resultSetToList(resultSet: relationalStore.ResultSet): ArrayList<EmojiRep> {
    let columnInfo = EmojiRep.getColumnInfo()
    let mapList = toEntityList(columnInfo, resultSet)
    if (null == mapList || mapList == undefined) {
      return new ArrayList()
    }
    return EmojiRep.mapListToEntityList(mapList)
  }

  static resultSetToOne(resultSet: relationalStore.ResultSet): EmojiRep | null {
    let list = EmojiRep.resultSetToList(resultSet)
    if (list.length > 0) {
      return list.removeByIndex(0);
    }
    return null
  }

  toJson(): ValuesBucket {
    return { _ID: this.id ? this.id : null, NAME: this.name ? this.name : null };
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
}

interface IJsonEmojiRep {
  _ID: number;
  NAME: string
}

export interface IEmojiRep {
  id?: number | null;
  name?: string | null;
}
