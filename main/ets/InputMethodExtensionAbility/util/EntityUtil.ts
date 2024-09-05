import relationalStore from '@ohos.data.relationalStore';
import ArrayList from '@ohos.util.ArrayList';
import { ColumnInfo, ColumnType } from '../entity/ColumnInfo';
import Logger from './Logger';


/**
 * 驼峰命名风格转为下划线命名风格
 * example: myVariableName ==> my_variable_name
 * @param str
 * @returns
 */
function toSnakeCase(str: string): string {
  if ("id" == str) {
    return "_id";
  }
  const words = str.replace(/([A-Z])/g, ' $1').split(' ');
  const snakeCase = words.map(word => word.toLowerCase().replace(/\b\w/g, (match) => `_${match}`)).join('');
  return snakeCase.slice(1)
}

export class EntityInfo {
  // 所有列名
  allColumns: string[]
  // 所有类型
  allTypes: string[]
}

export function toEntityList(columnInfos: ColumnInfo[],
  resultSet: relationalStore.ResultSet): Map<string, string | number | Date | null>[] {
  let rowCount = resultSet.rowCount
  if (rowCount === -1 || rowCount === 0 || typeof rowCount === 'string') {
    return []
  }
  resultSet.goToFirstRow();
  let dataMapList: Map<string, any>[] = []
  for (let i = 0; i < rowCount; i++) {
    let rowDataMap = new Map<string, any>()
    for (let columnInfo of columnInfos) {
      let entityType = columnInfo.entityType
      // 大写下划线命名风格 example: USER_HEAD
      let columnName = columnInfo.name
      let columnIndex = resultSet.getColumnIndex(columnName)
      if (columnIndex != -1) {
        let value: any
        try {
          if ("string" == entityType) {
            value = resultSet.getString(columnIndex)
          } else if ("number" == entityType) {
            value = resultSet.getLong(columnIndex)
          } else {
            value = resultSet.getString(columnIndex)
          }
          rowDataMap.set(columnName, value)
        } catch (err) {
          Logger.error(`err is ${err}`)
        }
      }

    }
    dataMapList[i] = rowDataMap
    resultSet.goToNextRow();
  }
  return dataMapList
}

export function objToString(obj: any): string {
  if (undefined == obj || null == obj) {
    return ""
  }
  return obj as string
}

export function objToBoolean(obj: any): boolean {
  if (undefined == obj || null == obj) {
    return false
  }
  return typeof obj == "string" && "true" == (obj as string).toLowerCase()
}

export function objToUint8Array(obj: any): Uint8Array {
  if (undefined == obj || null == obj) {
    return new Uint8Array(0)
  }
  return obj as Uint8Array
}


export function objToNumber(obj: any): number {
  if (undefined == obj || null == obj) {
    return 0
  }
  return parseInt(obj)
}

export function objToDate(obj: any): Date {
  if (undefined == obj || null == obj) {
    return null
  }
  return new Date(parseInt(obj))
}

export function toOneResult<T>(entityType: ColumnType, resultSet: relationalStore.ResultSet): T {
  let rowCount = resultSet.rowCount
  if (rowCount === 0 || typeof rowCount === 'string') {
    return null
  }
  resultSet.goToFirstRow();
  let result: any
  for (let i = 0; i < rowCount; i++) {
    let value: any
    if (ColumnType.STRING == entityType) {
      value = resultSet.getString(0)
    } else if (ColumnType.LONG == entityType) {
      value = resultSet.getLong(0)
    } else {
      value = resultSet.getString(0)
    }
    result = value
    resultSet.goToNextRow();
  }
  return result
}

export function toOneResultList<T>(entityType: ColumnType, resultSet: relationalStore.ResultSet): ArrayList<T> {
  let rowCount = resultSet.rowCount
  if (rowCount === 0 || typeof rowCount === 'string') {
    return null
  }
  resultSet.goToFirstRow();
  let list: ArrayList<T> = new ArrayList()
  for (let i = 0; i < rowCount; i++) {
    let value: any
    if (ColumnType.STRING == entityType) {
      value = resultSet.getString(0)
    } else if (ColumnType.LONG == entityType) {
      value = resultSet.getLong(0)
    } else {
      value = resultSet.getString(0)
    }
    list.add(value)
    resultSet.goToNextRow();
  }
  return list
}

export function arrayToPlaceholders(a: string[]): string {
  const placeholders = a.map(() => '?').join(', ');
  return `(${placeholders})`;
}

export function listToPlaceholders(a: ArrayList<string>): string {
  const placeholders = a.convertToArray().map(() => '?').join(', ');
  return `(${placeholders})`;
}

/**
 * 移除undefined的值
 * @param obj
 * @returns
 */
export function removeUndefinedValues<T extends object>(obj: T): T {
  const result: T = {} as any;
  for (const key in obj) {
    if (obj.hasOwnProperty(key) && obj[key] !== undefined) {
      result[key] = obj[key];
    }
  }
  return result;
}
