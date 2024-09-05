import { relationalStore } from '@kit.ArkData';
import GlobalContext from '../context/GlobalContext';
import { getInitWordSql } from './InitSql';
import { BusinessError } from '@kit.BasicServicesKit';
import WordRepImport from './WordRepImport';
import { common } from '@kit.AbilityKit';

namespace RdbManager {
  /**
   * 初始化数据库
   */
  export function initDb(context: common.Context) {
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'Words.db', // 数据库文件名
      securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别
      encrypt: false, // 可选参数，指定数据库是否加密，默认不加密
      // dataGroupId: 'dataGroupID', // 可选参数，仅可在Stage模型下使用，表示为应用组ID，需要向应用市场获取。指定在此Id对应的沙箱路径下创建实例，当此参数不填时，默认在本应用沙箱目录下创建。
      // customDir: 'customDir/subCustomDir' // 可选参数，数据库自定义路径。数据库将在如下的目录结构中被创建：context.databaseDir + '/rdb/' + customDir，其中context.databaseDir是应用沙箱对应的路径，'/rdb/'表示创建的是关系型数据库，customDir表示自定义的路径。当此参数不填时，默认在本应用沙箱目录下创建RdbStore实例。
    };
    let store: relationalStore.RdbStore | undefined = undefined;
    let initSql: string[] = getInitWordSql();

    relationalStore.getRdbStore(context, STORE_CONFIG, (err: BusinessError, rdbStore: relationalStore.RdbStore) => {
      store = rdbStore;
      GlobalContext.getContext().setWordDb(store)

      if (err) {
        console.error(`Get RdbStore failed, code is ${err.code},message is ${err.message}`);
        return;
      }

      // 当数据库创建时，数据库默认版本为0
      if (store.version === 0) {
        initSql.forEach((sql) => {
          store?.executeSql(sql); // 创建数据表
        })
        // 设置数据库的版本，入参为大于0的整数
        store.version = 1;
      }
      // 导入词库
      WordRepImport.copyDbFileToStorage()
    })
  }
}

export default RdbManager