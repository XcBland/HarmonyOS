/**
 * 词库导入
 */
import { Context } from '@ohos.arkui.UIContext'
import fs, { Options } from '@ohos.file.fs';
import { BusinessError, systemDateTime } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import KeyboardController from '../model/KeyboardController';
import GlobalContext from '../context/GlobalContext';
import Logger from '../util/Logger';
import { convertMsToHMS } from '../util/TimeUtil';
import { taskpool } from '@kit.ArkTS';


namespace WordRepImport {

  /**
   * 词库还原
   */
  export async function copyDbFileToStorage() {
    let wordDb = GlobalContext.getContext().getWordDb()
    if (wordDb.version > 1) {
      Logger.info('词库无需初始化...')
      return
    }

    // 应用沙箱路径
    let mContext: common.UIAbilityContext = GlobalContext.getContext().getObject('mContext') as common.UIAbilityContext
    let resourceManager = mContext.resourceManager
    let databaseDir = mContext.databaseDir
    let filePath = 'lexicon.db'
    // 词库路径
    let repDir = databaseDir + '/rdb'
    let targetPath = repDir + "/lexicon.db"
    resourceManager.getRawFd(filePath, (err, rawfd) => {
      if (rawfd) {
        if (!fs.accessSync(repDir)) {
          fs.mkdirSync(repDir)
        }
        if (!fs.accessSync(targetPath)) {
          Logger.error(targetPath + '文件不存在')
        } else {
          // fs.unlinkSync(targetPath)
          // 词库存在不再进行初始化操作
          return
        }
        // 自Unix纪元以来经过的时间。默认为毫秒数
        let startTime = systemDateTime.getTime()

        let destFile = fs.openSync(targetPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)

        let buffSize: number = 4096;
        let buffer: ArrayBuffer = new ArrayBuffer(buffSize);
        let off: number = 0; // 记录读取位置的偏移（相较于文件起始偏移）
        let len: number = 0; // 本次读取内容的实际长度
        let readedLen: number = 0; // 记录已读文件长度
        while (len = fs.readSync(rawfd.fd, buffer, { offset: rawfd.offset + off, length: buffSize })) {
          readedLen += len;
          fs.writeSync(destFile.fd, buffer, { offset: off, length: len });
          off = off + len;
          if ((rawfd.length - readedLen) < buffSize) {
            buffSize = rawfd.length - readedLen;
          }
        }

        //fs.copyFileSync(rawfd.fd, file.fd, 0);
        fs.closeSync(destFile.fd)

        wordDb.restore('lexicon.db', (err) => {
          if (err) {
            console.error(`Restore failed, code is ${err.code},message is ${err.message}`);
            return;
          }
          //
          Logger.info('导入词库成功');
          let endTime = systemDateTime.getTime()
          let betweenMs = (endTime - startTime)
          let betweenStr = convertMsToHMS(betweenMs)
          Logger.info('导入词库耗时:' + betweenStr + " ," + betweenMs + "ms")
          wordDb.version = 2
        })


      }
    })

  }

  export async function copySqlFileToStorage() {
    // 应用沙箱路径
    let mContext: common.UIAbilityContext = GlobalContext.getContext().getObject('mContext') as common.UIAbilityContext
    let resourceManager = mContext.resourceManager
    let filesDir = mContext.filesDir
    let filePath = 'words_v1.0.sql'
    // 词库路径
    let repDir = filesDir + '/rep'
    let targetPath = repDir + "/words_v1.0.sql"
    resourceManager.getRawFd(filePath, (err, rawfd) => {
      if (rawfd) {
        if (!fs.accessSync(repDir)) {
          fs.mkdirSync(repDir)
        }
        if (!fs.accessSync(targetPath)) {
          Logger.error(targetPath + '文件不存在')
        } else {
          // fs.unlinkSync(targetPath)
          // 词库存在不再进行初始化操作
          return
        }
        // 自Unix纪元以来经过的时间。默认为毫秒数
        let startTime = systemDateTime.getTime()

        let destFile = fs.openSync(targetPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)

        let buffSize: number = 4096;
        let buffer: ArrayBuffer = new ArrayBuffer(buffSize);
        let off: number = 0; // 记录读取位置的偏移（相较于文件起始偏移）
        let len: number = 0; // 本次读取内容的实际长度
        let readedLen: number = 0; // 记录已读文件长度
        while (len = fs.readSync(rawfd.fd, buffer, { offset: rawfd.offset + off, length: buffSize })) {
          readedLen += len;
          fs.writeSync(destFile.fd, buffer, { offset: off, length: len });
          off = off + len;
          if ((rawfd.length - readedLen) < buffSize) {
            buffSize = rawfd.length - readedLen;
          }
        }

        //fs.copyFileSync(rawfd.fd, file.fd, 0);
        fs.closeSync(destFile.fd)
        let options: Options = {
          encoding: 'utf-8'
        };

        let tempSql = ''
        fs.readLines(targetPath, options).then((readerIterator: fs.ReaderIterator) => {
          for (let it = readerIterator.next();!it.done; it = readerIterator.next()) {
            console.info("content: " + it.value);
            tempSql += it.value
            if (tempSql.indexOf(';') != -1) {
              // 执行sql
              let wordDb = GlobalContext.getContext().getWordDb()
              wordDb.execute(tempSql)
              Logger.info('词库导入:' + tempSql)
              tempSql = ''
            }
          }
          //
          Logger.info('导入词库成功');
          let endTime = systemDateTime.getTime()
          let betweenMs = (endTime - startTime)
          let betweenStr = convertMsToHMS(betweenMs)
          Logger.info('导入词库耗时:' + betweenStr + " ," + betweenMs + "ms")
        }).catch((err: BusinessError) => {
          console.error("readLines failed with error message: " + err.message + ", error code: " + err.code);
        });

      }
    })

  }
}

export default WordRepImport