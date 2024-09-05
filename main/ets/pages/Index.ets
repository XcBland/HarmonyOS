import { KeyButtonData } from '../InputMethodExtensionAbility/data/KeyButtonDataManager';
import { BottomTool } from '../InputMethodExtensionAbility/pages/InputIndex';
import { MainInputPanel } from '../InputMethodExtensionAbility/view/MainInputPanl';
import { EnglishMainInputPanel } from '../InputMethodExtensionAbility/view/EnglishMainInputPanl';
import { SmartSuggestionBar, SuggestionWord } from '../InputMethodExtensionAbility/view/SmartSuggestionBar';
import { PinyinDataSource, WordSuggestDataSource } from '../InputMethodExtensionAbility/dao/DataSouce';
import WordRepImport from '../InputMethodExtensionAbility/dao/WordRepImport';
import { PinyinDetailView } from '../InputMethodExtensionAbility/view/PinyinDetailView';
import { inputMethod } from '@kit.IMEKit';
import { CN_SUB_TYPE_ID } from '../InputMethodExtensionAbility/constant/InputMethConstant';
import { CustomInput } from '../InputMethodExtensionAbility/view/CustomInput';
import { EmojiPanel } from '../InputMethodExtensionAbility/view/EmojiPanel';

@Entry
@Component
struct Index {
  // 记录输入的键值
  @Provide inputContent: Array<KeyButtonData> = []
  // 是否为数字键盘格式
  @Provide numberMode: boolean = false;
  // 英文输入法模式
  @State englishMode: boolean = false
  @Provide showPinYinListPage: boolean = false;
  @Provide pinyinList: PinyinDataSource = new PinyinDataSource();
  @Provide pageWords: WordSuggestDataSource = new WordSuggestDataSource()
  // 用于更新预览文本
  @Provide previewTextUpdate: boolean = false;
  // 是否展示表情面板
  @Provide showEmojiPanel: boolean = false;

  build() {
    Column() {
      Row() {
        Column({ space: 5 }) {
          TextInput()
          Button("切换至" + (this.englishMode ? "中" : "英") + "文输入法界面")
            .backgroundColor(Color.Transparent)
            .borderColor(Color.Black)
            .fontColor(Color.Black)
            .type(ButtonType.Normal)
            .onClick(() => {
              this.englishMode = !this.englishMode;
            })
        }.width('100%').height(50)

      }.width('100%').height('50%')
      .backgroundColor(Color.Transparent)

      Row() {
        Stack() {

          if (this.englishMode) {
            Column({ space: 5 }) {
              if (this.showEmojiPanel) {
                EmojiPanel()
              } else {
                SmartSuggestionBar()
                EnglishMainInputPanel()
              }

            }.width('100%').height('100%')
          } else {
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
        }

      }.width('100%').height('50%')
    }

    .height('100%')
    .width('100%')
  }

  aboutToAppear(): void {
    let subType = inputMethod.getCurrentInputMethodSubtype()
    if (subType == null || subType.id == CN_SUB_TYPE_ID) {
      this.englishMode = false
    } else {
      this.englishMode = true
    }
  }
}
