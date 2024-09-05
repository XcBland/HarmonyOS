import { US_SUB_TYPE_ID } from '../constant/InputMethConstant';
import { PinyinDataSource, WordSuggestDataSource } from '../dao/DataSouce';
import { KeyButtonData } from '../data/KeyButtonDataManager';
import { switchInputSubtype } from '../util/SwitchUtil';
import { EmojiPanel } from '../view/EmojiPanel';
import { EnglishMainInputPanel } from '../view/EnglishMainInputPanl';
import { SmartSuggestionBar, SuggestionWord } from '../view/SmartSuggestionBar';
import { BottomTool } from './InputIndex';


@Component
@Entry
struct EnglishInputIndex {
  // 记录输入的键值
  // @State  inputContent:Array<KeyButtonData> = []
  // 是否为数字键盘格式
  // @State numberMode:boolean = true;

  @Provide inputContent: Array<KeyButtonData> = []
  // // 是否为数字键盘格式
  @Provide numberMode: boolean = true;
  @Provide showPinYinListPage: boolean = false;
  @Provide pinyinList: PinyinDataSource = new PinyinDataSource();
  // 用于更新预览文本
  @Provide previewTextUpdate: boolean = false;
  @Provide pageWords: WordSuggestDataSource = new WordSuggestDataSource()
  // 是否展示表情面板
  @Provide showEmojiPanel: boolean = false;

  aboutToAppear(): void {
    this.numberMode = false
    switchInputSubtype(US_SUB_TYPE_ID)
  }

  build() {
    Stack() {
      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.End
      }) {
        Flex({
          direction: FlexDirection.Column,
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Column({ space: 8 }) {
            if (this.showEmojiPanel) {
              EmojiPanel()
            } else {
              SmartSuggestionBar()
              EnglishMainInputPanel()
            }

          }.width('100%').height('100%')
          .backgroundColor("#eff0f4")

        }
        .align(Alignment.End)
        .width("100%")
        .height("100%")
      }
      .height("100%").align(Alignment.End).backgroundColor("#eff0f4")

    }
    .position({ x: 0, y: 0 }).zIndex(99999)
  }
}

