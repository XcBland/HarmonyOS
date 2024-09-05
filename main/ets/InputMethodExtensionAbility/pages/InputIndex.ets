import { CN_SUB_TYPE_ID } from '../constant/InputMethConstant';
import { PinyinDataSource, WordSuggestDataSource } from '../dao/DataSouce';
import { KeyButtonData } from '../data/KeyButtonDataManager';
import { switchInputSubtype } from '../util/SwitchUtil';
import { CustomInput } from '../view/CustomInput';
import { EmojiPanel } from '../view/EmojiPanel';
import { MainInputPanel } from '../view/MainInputPanl';
import { PinyinDetailView } from '../view/PinyinDetailView';
import { SmartSuggestionBar, SuggestionWord } from '../view/SmartSuggestionBar';


@Component
export struct BottomTool {
  build() {
    Row() {
      Button() {
        Image($r('app.media.keyboard')).width(40).height(40)
          .padding(5)
      }.backgroundColor(Color.Transparent)
      .width(40).height(40)

      Blank()
      Button() {
        Image($r('app.media.paste'))
          .padding(8)
      }.backgroundColor(Color.Transparent)
      .width(40).height(40)
    }.width('100%').height(40)
    .backgroundColor(Color.Transparent)
    .padding({ left: 16, right: 16, top: 2 })
  }
}


@Component
@Entry
struct InputIndex {
  // 记录输入的键值
  @Provide inputContent: Array<KeyButtonData> = []
  // 是否为数字键盘格式
  @Provide numberMode: boolean = false;
  @Provide showPinYinListPage: boolean = false;
  @Provide pinyinList: PinyinDataSource = new PinyinDataSource();
  @Provide pageWords: WordSuggestDataSource = new WordSuggestDataSource()
  // 用于更新预览文本
  @Provide previewTextUpdate: boolean = false;
  // 是否展示表情面板
  @Provide showEmojiPanel: boolean = false;

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
          Column({ space: 5 }) {

            if (this.showEmojiPanel) {
              EmojiPanel()
            } else {
              SmartSuggestionBar()
              if (this.showPinYinListPage) {
                PinyinDetailView()
              } else {
                MainInputPanel()
              }

            }

          }.width('100%').height('100%')

        }
        .align(Alignment.End)
        .width("100%")
        .height("100%")
      }
      .height("100%").align(Alignment.End).backgroundColor("#eff0f4")

    }
    .position({ x: 0, y: 0 }).zIndex(99999)
  }

  aboutToAppear(): void {
    switchInputSubtype(CN_SUB_TYPE_ID)
  }
}

