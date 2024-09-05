import GlobalContext from '../context/GlobalContext'
import { Emoji } from '../entity/Emoji'
import { relationalStore } from '@kit.ArkData';
import Logger from '../util/Logger';


namespace EmojiService {

  export async function getByRepId(repId: number, callback: (list: Array<Emoji>) => void) {
    let store = GlobalContext.getContext().getWordDb()
    let predicates = new relationalStore.RdbPredicates(Emoji.getTableName());
    predicates.equalTo('rep_id', repId)
    store.query(predicates, (err, resultSet) => {
      if (err) {
        Logger.error('查询表情异常' + err)
        callback([])
      }
      let list = Emoji.resultSetToList(resultSet)
      callback(list.convertToArray())
    })
  }

}

export default EmojiService