import ArrayList from '@ohos.util.ArrayList';
import relationalStore from '@ohos.data.relationalStore';
import { ValuesBucket } from '@kit.ArkData';
import { ColumnInfo } from './ColumnInfo';
import { objToNumber, objToString, toEntityList } from '../util/EntityUtil';

/**
 *
 * @TableName word_rep
 */
export class WordRep {
  /**
   * 词库id
   */
  id: number = 0;
  /**
   * 词库名称
   */
  name: string = '';
  /**
   * 词库创建时间，时间戳
   */
  createTime: number = 0;

  constructor(data: IWordRep = {}) {
    if (data.id) {
      this.id = data.id;
    }
    if (data.name) {
      this.name = data.name;
    }
    if (data.createTime) {
      this.createTime = data.createTime;
    }
  }

  static getTableName(): string {
    return "WORD_REP";
  }

  static getColumnInfo(): ColumnInfo[] {
    return [new ColumnInfo("_ID", "number"), new ColumnInfo("NAME", "string"), new ColumnInfo("CREATE_TIME", "number")];
  }

  static mapToEntity(map: Map<string, string | number | Date | null>): WordRep {
    let entity = new WordRep();
    let id = objToNumber(map.get("_ID"))
    entity.id = id;
    let name = objToString(map.get("NAME"))
    entity.name = name;
    let createTime = objToNumber(map.get("CREATE_TIME"))
    entity.createTime = createTime;
    return entity;
  }

  static mapListToEntityList(mapList: Map<string, string | number | Date | null>[]): ArrayList<WordRep> {
    let list = new ArrayList<WordRep>()
    if (null == mapList || mapList == undefined) {
      return list
    }
    for (let map of mapList) {
      let entity = WordRep.mapToEntity(map)
      list.add(entity)
    }
    return list;
  }

  static resultSetToList(resultSet: relationalStore.ResultSet): ArrayList<WordRep> {
    let columnInfo = WordRep.getColumnInfo()
    let mapList = toEntityList(columnInfo, resultSet)
    if (null == mapList || mapList == undefined) {
      return new ArrayList()
    }
    return WordRep.mapListToEntityList(mapList)
  }

  static resultSetToOne(resultSet: relationalStore.ResultSet): WordRep | null {
    let list = WordRep.resultSetToList(resultSet)
    if (list.length > 0) {
      return list.removeByIndex(0);
    }
    return null
  }

  toJson(): ValuesBucket {
    return {
      _ID: this.id ? this.id : null,
      NAME: this.name ? this.name : null,
      CREATE_TIME: this.createTime ? this.createTime : null
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

  setCreateTime(createTime: number): void {
    this.createTime = createTime;
  }

  getCreateTime(): number {
    return this.createTime;
  }
}

interface IJsonWordRep {
  _ID: number;
  NAME: string;
  CREATE_TIME: number
}

export interface IWordRep {
  id?: number | null;
  name?: string | null;
  createTime?: number | null;
}
