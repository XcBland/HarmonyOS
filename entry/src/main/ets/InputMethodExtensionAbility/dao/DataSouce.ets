// Basic implementation of IDataSource to handle data listener
import { SuggestionWord } from '../view/SmartSuggestionBar';
import { HashMap, util } from '@kit.ArkTS';
import { KeyButtonData } from '../data/KeyButtonDataManager';
import { getKeyMapFromPinyinGroup, NineGridKeyCodeData } from '../data/NineGridKeyCodeManager';


export class BasicDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: T[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): T {
    return this.originDataArray[index];
  }

  // 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  // 该方法为框架侧调用，为对应的LazyForEach组件在数据源处去除listener监听
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  // 通知LazyForEach组件需要重载所有子组件
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  // 通知LazyForEach组件需要在index对应索引处添加子组件
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  // 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  // 通知LazyForEach组件需要在index对应索引处删除该子组件
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  // 通知LazyForEach组件将from索引和to索引处的子组件进行交换
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }
}

/**
 * 左侧拼音列表实体
 */
export class PinyinGroup {
  name: string = '';
  id: string = ''
  keys: Array<KeyButtonData> = []

  constructor(name: string, id: string, keys: Array<KeyButtonData>) {
    this.name = name;
    this.id = id;
    this.keys = keys;
  }
}

export class PinyinDataSource extends BasicDataSource<PinyinGroup> {
  private dataArray: PinyinGroup[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): PinyinGroup {
    return this.dataArray[index];
  }


  public addData(index: number, data: PinyinGroup): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: PinyinGroup): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public replaceAllData(datas: Array<PinyinGroup>): void {
    this.updateId(datas)
    this.dataArray = datas;
    this.notifyDataReload()
  }

  public updateId(datas: Array<PinyinGroup>): void {
    if (datas) {
      datas.forEach((value) => {
        value.id = util.generateRandomUUID()
      })
    }
  }

  /**
   * 获取拼音map
   * @returns
   */
  public getPinYinKeyMap(): HashMap<string, NineGridKeyCodeData> {
    return getKeyMapFromPinyinGroup(this.dataArray)
  }

  /**
   * 清理数据
   */
  public clearData() {
    this.dataArray = []
    this.notifyDataReload()
  }
}


export class WordSuggestDataSource extends BasicDataSource<SuggestionWord> {
  private dataArray: SuggestionWord[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): SuggestionWord {
    return this.dataArray[index];
  }


  public addData(index: number, data: SuggestionWord): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: SuggestionWord): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public replaceAllData(datas: Array<SuggestionWord>): void {
    this.updateId(datas)
    this.dataArray = datas;
    this.notifyDataReload()
  }

  /**
   * 追加所有数据
   * @param datas
   */
  public appendAllData(datas: Array<SuggestionWord>, inFirst: boolean): void {
    if (inFirst) {
      this.dataArray = datas.concat(this.dataArray)
    } else {
      this.dataArray = this.dataArray.concat(datas)
    }
    this.notifyDataReload()
  }

  public updateId(datas: Array<SuggestionWord>): void {
    if (datas) {
      datas.forEach((value) => {
        value.id = util.generateRandomUUID()
      })
    }
  }
}