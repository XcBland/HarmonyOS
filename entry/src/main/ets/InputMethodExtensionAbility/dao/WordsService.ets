import GlobalContext from '../context/GlobalContext';
import { Words } from '../entity/Words'
import { ArrayList, HashMap } from '@kit.ArkTS';
import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../util/Logger';
import {
  getPinyinList,
  getPinyinStrList,
  getPreviewTextLockedState,
  PreviewTextLockedState,
  QueryParam
} from '../util/SpellToWordUtil';
import { KeyButtonData } from '../data/KeyButtonDataManager';
import { SuggestionWord } from '../view/SmartSuggestionBar';
import { PopularPinyinWords } from '../entity/PopularPinyinWords';

namespace WordService {

  /**
   * 通过拼音模糊查询
   * @param pageIndex
   * @param pageSize
   * @returns
   */
  export function queryByKeywordPage(keyword: string, pageIndex: number, pageSize: number,
    callback: (result: ArrayList<Words>) => void): void {
    let store = GlobalContext.getContext().getWordDb()
    if (!store) {
      Logger.error('store err , store is ' + store)
      callback(new ArrayList())
    }
    let offset = (pageIndex - 1) * pageSize;
    let likeCondition = "" + keyword + "%"
    let querySql = 'select * from words where pinyin like ? order by pinyin, frequency desc limit ? offset ?'
    store.querySql(querySql, [likeCondition, pageSize, offset], (err, resultSet) => {
      if (err) {
        Logger.error(err.message)
        callback(new ArrayList())
        return
      }
      let list = Words.resultSetToList(resultSet)
      callback(list)
    })
  }

  /**
   * 通过拼音前缀和完整的九宫格编码、字符长度查询，用于部分锁定字符查询
   * @param pinyinPrefix
   * @param nineGridKeyCode
   * @param wordLen
   * @param callback
   */
  export function queryByPinyinPrefixAndNineGridCode(pinyinPrefix: string, nineGridKeyCode: string, wordLen: number,
    callback: (result: Array<Words>) => void) {
    let store = GlobalContext.getContext().getWordDb()
    if (!store) {
      Logger.error('store err , store is ' + store)
      callback([])
    }
    let pinyinCondition = pinyinPrefix + "%"
    let nineGridKeyCodeCondition = nineGridKeyCode + "%"
    let querySql = "SELECT * FROM words WHERE pinyin  LIKE ? AND nine_grid_key_code like ? AND LENGTH(word) = ?";
    // let sql = "SELECT * FROM words WHERE pinyin  LIKE 'chong%' AND nine_grid_key_code like '246647%' AND LENGTH(word) = 2";
    store.querySql(querySql, [pinyinCondition, nineGridKeyCodeCondition, wordLen], (err, resultSet) => {
      if (err) {
        Logger.error(err.message)
        callback([])
        return
      }
      let list = Words.resultSetToList(resultSet)
      callback(list.convertToArray())
    })
  }

  /**
   * 通过不同的按钮类型查询联想词
   * @param queryParam
   * @param callback
   */
  export function queryByParam(queryParam: QueryParam, callback: (result: Words[]) => void) {
    let store = GlobalContext.getContext().getWordDb()
    if (!store) {
      Logger.error('store err , store is ' + store)
      callback([])
    }

    let state = queryParam.previewTextLockState
    let nineGridKeyCode = queryParam.nineGridKeyCode
    let lockedPreviewText = queryParam.lockedPreviewText
    let previewText = queryParam.previewText
    let firstWordSql = getFirstWordAppendSql(queryParam.keys)
    let pageIndex = queryParam.pageIndex
    let pageSize = queryParam.pageSize

    let sql = ''
    if (state == PreviewTextLockedState.ALL_LOCKED || state == PreviewTextLockedState.PART_LOCKED) {
      sql = getPartLockSql(state, lockedPreviewText, previewText, nineGridKeyCode, firstWordSql, pageIndex, pageSize)
    } else {
      sql = getUnlockWordSql(previewText, nineGridKeyCode, firstWordSql, pageIndex, pageSize)
    }


    Logger.info(`查询的sql为: ${sql}`)
    store.querySql(sql, [], (err, resultSet) => {
      if (err) {
        Logger.error(err.message)
        callback([])
        return
      }
      let list = Words.resultSetToList(resultSet)
      callback(list.convertToArray())
    })
  }

  /**
   *
   * @param lockedText
   * @param previewTextPinyin
   * @param nineGridKeyCode
   * @returns
   */
  export function getPartLockSql(state: PreviewTextLockedState, lockedText: string, previewTextPinyin: string,
    nineGridKeyCode: string, firstWordSql: string, pageIndex: number, pageSize: number): string {
    //  查询预输入文本相关的拼音
    let offset = (pageIndex - 1) * pageSize;
    let fullPinyin = previewTextPinyin.replaceAll("'", "")
    let split = previewTextPinyin.split("'").filter((v) => v != "")
    // 词语长度
    let wordLen = split.length
    // 获取锁定部分的第一个词
    let fullLockPinyin = lockedText.replaceAll("'", "")
    let lockSplit = lockedText.split("'")
    let firstPinyin: string = ''
    if (lockSplit.length > 0) {
      firstPinyin = lockSplit[0]
    }

    let sql =
      `select * from ( SELECT * FROM words w WHERE pinyin = '${fullPinyin}' AND LENGTH(word) = ${wordLen}  ORDER BY frequency DESC)` +
        `UNION ALL SELECT * FROM words w WHERE pinyin LIKE '${fullPinyin}%' AND LENGTH(word) = ${wordLen} `
    // 全部锁定不做模糊查询
    if (state == PreviewTextLockedState.PART_LOCKED) {
      sql += `UNION ALL  SELECT * FROM words WHERE pinyin  LIKE '${fullLockPinyin}%' AND nine_grid_key_code like '${nineGridKeyCode}%' AND LENGTH(word) = ${wordLen}  `
      sql += firstWordSql
      sql += `UNION ALL SELECT * FROM words w WHERE pinyin LIKE '${firstPinyin}%' AND LENGTH(word) = 1 `
    } else {
      sql += firstWordSql
    }

    if (pageSize != -1) {
      // 数据量大会影响性能
      sql = sql + ` limit ${pageSize} offset ${offset} \n`
    }

    return sql
  }


  /**
   * 获取未锁定的查询sql
   * @param previewTextPinyin
   * @param nineGridKeyCode
   * @returns
   */
  export function getUnlockWordSql(previewTextPinyin: string, nineGridKeyCode: string, firstWordSql: string,
    pageIndex: number, pageSize: number) {

    let offset = (pageIndex - 1) * pageSize;
    //  查询预输入文本相关的拼音
    let split = previewTextPinyin.split("'")
    let fullPinyin = previewTextPinyin.replaceAll("'", "")
    let pinyinCondition = ""
    split.forEach((pinyin) => {
      pinyinCondition = pinyin + "%"
    })
    // 词语长度
    let wordLen = split.length
    let sql = `SELECT * FROM words w2 WHERE LENGTH(word) = ${wordLen} AND pinyin = '${fullPinyin}' \n`
      + `UNION ALL SELECT * FROM words w2 WHERE LENGTH(word) = ${wordLen} AND pinyin LIKE '${pinyinCondition}' \n`
      + "UNION ALL\n"
      // 查询九宫格编码匹配的词汇
      + `SELECT * FROM words  WHERE LENGTH(word) = ${wordLen} AND  nine_grid_key_code LIKE '${nineGridKeyCode}%' \n`
      + firstWordSql + "\n"

    if (pageSize != -1) {
      sql = sql + `limit ${pageSize} offset ${offset} \n`
    }
    return sql
  }

  /**
   * 获取第一个词汇部分sql
   */
  export function getFirstWordAppendSql(keys: Array<KeyButtonData>): string {
    let state = getPreviewTextLockedState(keys)
    if (state == PreviewTextLockedState.ALL_LOCKED || state == PreviewTextLockedState.PART_LOCKED) {
      let lockFirstPinyin = ''
      let firstKey: KeyButtonData | null = null
      for (let i = 0; i < keys.length; i++) {
        let key = keys[i]
        let createWord = key.createWord
        if (createWord) {
          continue
        }
        lockFirstPinyin += key.selectStr
        if (key.isEnd) {
          firstKey = key
          break
        }
      }
      // 判断第一个词是否锁定
      if (firstKey && firstKey.locked) {
        let sql =
          `UNION ALL select * from (SELECT * FROM words w WHERE pinyin = '${lockFirstPinyin}' AND LENGTH(word) = 1 ORDER BY frequency DESC) \n` +
            `UNION ALL SELECT * FROM words w WHERE pinyin LIKE '${lockFirstPinyin}%' AND LENGTH(word) = 1\n`
        return sql
      } else {
        // 未锁定则由九宫格编码进行模糊查询
        let sql: string = getFirstWordSqlByNineGridKeyCode(keys);
        return sql;
      }

    } else {
      let sql: string = getFirstWordSqlByNineGridKeyCode(keys);
      return sql;
    }

  }

  function getFirstWordSqlByNineGridKeyCode(keys: KeyButtonData[]) {
    let pinyinAndNineGridCode = getPinyinStrList(keys);
    let sql: string = '';
    pinyinAndNineGridCode.forEach((value) => {
      let partSql = `SELECT * FROM words WHERE LENGTH(word) = 1 AND  pinyin LIKE '${value.pinyin}%'\n`;
      let partEqSql = `SELECT * FROM words WHERE LENGTH(word) = 1 AND  pinyin = '${value.pinyin}'\n`;
      sql = sql + `UNION ALL ${partEqSql} UNION ALL ${partSql} \n`;
    });
    return sql;
  }

  /**
   * 通过九宫格编码查询
   * @param nineGridKeyCode
   * @param keyword
   * @param pageIndex
   * @param pageSize
   * @param callback
   */
  export function queryByNineGridKeyCode(nineGridKeyCode: string, pinyin: string, pageIndex: number, pageSize: number,
    callback: (result: ArrayList<Words>) => void): void {
    let store = GlobalContext.getContext().getWordDb()
    if (!store) {
      Logger.error('store err , store is ' + store)
      callback(new ArrayList())
    }
    let offset = (pageIndex - 1) * pageSize;
    let likeCondition = "" + nineGridKeyCode + "%"
    // 分词符号替换
    let pinyinLikeCondition = pinyin.replaceAll("'", "") + '%'
    let querySql =
      'select * from words where nine_grid_key_code like ? or pinyin like ? order by LENGTH(pinyin), pinyin, frequency desc limit ? offset ?'
    Logger.info(`execute: select * from words where nine_grid_key_code like '${likeCondition}' or pinyin like '${pinyinLikeCondition}' order by LENGTH(pinyin), pinyin, frequency desc limit ${pageSize} offset ${offset}`)
    store.querySql(querySql, [likeCondition, pinyinLikeCondition, pageSize, offset], (err, resultSet) => {
      if (err) {
        Logger.error(err.message)
        callback(new ArrayList())
        return
      }
      let list = Words.resultSetToList(resultSet)
      callback(list)
    })
  }

  export function queryByKeywordPageSync(keyword: string, pageIndex: number, pageSize: number): ArrayList<Words> {
    let store = GlobalContext.getContext().getWordDb()
    if (!store) {
      Logger.error('store err , store is ' + store)
      return new ArrayList()
    }

    let offset = (pageIndex - 1) * pageSize;
    let likeCondition = "" + keyword + "%"
    let querySql = 'select * from words where pinyin like ? order by pinyin, frequency desc limit ? offset ?'
    let resultSet = store.querySqlSync(querySql, [likeCondition, pageSize, offset])
    let list = Words.resultSetToList(resultSet)
    return list
  }


  /**
   * 根据拼音查询
   * @param keyword
   * @returns
   */
  export async function queryByKeyword(keyword: string, callback: (result: ArrayList<Words>) => void) {
    let store = GlobalContext.getContext().getWordDb()
    if (!store) {
      Logger.error('store err , store is ' + store)
      callback(new ArrayList())
    }
    let querySql = 'select * from words where pinyin = ? order by pinyin, frequency'
    store.querySql(querySql, [keyword], (err, resultSet) => {
      if (err) {
        Logger.error(err.message)
        callback(new ArrayList())
        return
      }
      let list = Words.resultSetToList(resultSet)
      callback(list)
    })

  }

  export function queryByKeywordSync(keyword: string): ArrayList<Words> {
    let store = GlobalContext.getContext().getWordDb()
    if (!store) {
      Logger.error('store err , store is ' + store)
      return new ArrayList()
    }
    let querySql = 'select * from words where pinyin = ? order by pinyin, frequency'
    let resultSet = store.querySqlSync(querySql, [keyword])
    let list = Words.resultSetToList(resultSet)
    return list
  }

  /**
   * 查询所有关键字开头，长度为x的数据
   * @param keyword
   * @param length
   * @returns
   */
  export async function queryAllByKeywordForLike(keyword: string, length: number,
    callback: (result: ArrayList<Words>) => void) {
    let store = GlobalContext.getContext().getWordDb()
    if (!store) {
      Logger.error('store err , store is ' + store)
      callback(new ArrayList())
    }
    let likeCondition = "" + keyword + "%"
    let querySql = 'select * from words where pinyin like ? AND LENGTH(word) = ? order by pinyin, frequency'
    store.querySql(querySql, [likeCondition, length], (err, resultSet) => {
      let list = Words.resultSetToList(resultSet)
      callback(list)
    })
  }

  export function queryAllByKeywordForLikeSync(keyword: string, length: number): ArrayList<Words> {
    let store = GlobalContext.getContext().getWordDb()
    if (!store) {
      Logger.error('store err , store is ' + store)
      return new ArrayList()
    }
    let likeCondition = "" + keyword + "%"
    let querySql = 'select * from words where pinyin like ? AND LENGTH(word) = ? order by pinyin, frequency'
    let resultSet = store.querySqlSync(querySql, [likeCondition, length])
    let list = Words.resultSetToList(resultSet)
    return list
  }


  /**
   * 更新使用频率，提升下一个词语出现的排序
   * @param frequency
   * @param wordId
   */
  export function updateFrequency(frequency: number, wordId: number) {
    // 修改数据
    let predicates = new relationalStore.RdbPredicates(Words.getTableName());
    predicates.equalTo('WORD_ID', wordId);
    let store = GlobalContext.getContext().getWordDb()
    const valueBucket1: relationalStore.ValuesBucket = {
      'FREQUENCY': frequency,
    };

    if (store !== undefined) {
      (store as relationalStore.RdbStore).update(valueBucket1, predicates, (err: BusinessError, rows: number) => {
        if (err) {
          console.error(`更新词语排序异常. Code:${err.code}, message:${err.message}`);
          return;
        }
      })
    }
  }

  /**
   *
   * @param pinyin
   * @param callback
   */
  export function queryPopularPinyinWords(pinyinList: string[],
    callback: (result: HashMap<string, Words>) => void): void {
    let store = GlobalContext.getContext().getWordDb()
    if (!store) {
      Logger.error('store err , store is ' + store)
      callback(new HashMap())
    }

    let predicates = new relationalStore.RdbPredicates(PopularPinyinWords.getTableName());
    predicates.in('pinyin', pinyinList)

    store.query(predicates, (err, resultSet) => {
      if (err) {
        Logger.error(err.message)
        callback(new HashMap())
        return
      }
      let list = Words.resultSetToList(resultSet)
      //
      let dataMap = new HashMap<string, Words>()
      list.forEach((data) => {
        dataMap.set(data.pinyin, data)
      })

      callback(dataMap)
    })
  }

  export function queryPopularPinyinWordsSync(pinyinList: string[],): HashMap<string, Words> {

    let store = GlobalContext.getContext().getWordDb()
    if (!store) {
      Logger.error('store err , store is ' + store)
      return new HashMap()
    }

    let predicates = new relationalStore.RdbPredicates(PopularPinyinWords.getTableName());
    predicates.in('pinyin', pinyinList)
    let resultSet = store.querySync(predicates)
    let list = Words.resultSetToList(resultSet)
    let dataMap = new HashMap<string, Words>()
    list.forEach((data) => {
      dataMap.set(data.pinyin, data)
    })
    return dataMap
  }

}

export default WordService