import EmojiService from '../dao/EmojiService'
import EmojiData from '../data/EmojiData'
import { Emoji } from '../entity/Emoji'
import KeyboardController from '../model/KeyboardController'

@Component
@Preview
export struct EmojiPanel {
  @State emojiList: Array<EmojiData.IEmoji> = EmojiData.getEmojiList()
  @State AllEmojiList: Array<Array<EmojiData.IEmoji>> = []
  @State emojiGroup: Array<EmojiData.IEmojiRep> = EmojiData.getEmojiRep()
  @State @Watch("onIndexUpdate") currentIndex: number = 0
  // @State showEmojiPanel:boolean = false;
  @Consume showEmojiPanel: boolean;
  // 是否展示表情面板
  private controller: TabsController = new TabsController()

  build() {
    Column({ space: 5 }) {
      // 工具栏
      Row() {
        Button("搜索").backgroundColor(Color.Transparent)
          .type(ButtonType.Normal)
          .fontColor(Color.Black)
        Button("颜文字").backgroundColor(Color.Transparent)
          .type(ButtonType.Normal)
          .fontColor(Color.Black)
        Button("表情包").backgroundColor(Color.Transparent)
          .type(ButtonType.Normal)
          .fontColor(Color.Black)
        Button() {
          Image($r('app.media.back'))
            .width(25).height(25)
        }.backgroundColor(Color.Transparent)
        .type(ButtonType.Normal)
        .fontColor(Color.Black)
        .onClick(() => {
          this.showEmojiPanel = false;
        })
      }.width('100%').height(50)
      .justifyContent(FlexAlign.SpaceAround)

      Tabs({ index: this.currentIndex, controller: this.controller }) {
        ForEach(this.emojiGroup, (item: EmojiData.IEmojiRep, index: number) => {
          TabContent() {
            Stack({ alignContent: Alignment.TopEnd }) {
              Grid() {
                ForEach(this.AllEmojiList[index], (item: EmojiData.IEmoji, index) => {
                  GridItem() {
                    Button() {
                      Text(item.character)
                        .fontSize(30)
                    }.backgroundColor(Color.Transparent)
                    .type(ButtonType.Normal)
                    .onClick(() => {
                      KeyboardController.insertText(item.character)
                    })
                  }
                }, (item: EmojiData.IEmoji, index: number) => item.character)
              }.columnsTemplate("1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr")
              .rowsGap(6)
              .width('100%')

              Button() {
                Row() {
                  Image($r('app.media.del'))
                    .width(40).height(30)
                    .padding(5)
                }.backgroundColor('#e4e8f1')
                .opacity(0.75)
                .borderRadius(30)
              }
              .backgroundColor(Color.Transparent)
              .type(ButtonType.Normal)
              .alignRules({
                top: { anchor: "__container__", align: VerticalAlign.Top },
                left: { anchor: "__container__", align: HorizontalAlign.End }
              })
              .onClick(() => {
                KeyboardController.deleteForward(1)
              })

            }.width('100%')
            .padding({ left: 10, right: 10 })

          }
          .tabBar(item.name)

        }, (item: EmojiData.IEmojiRep, index: number) => item.id + '')

      }
      .barMode(BarMode.Scrollable)
      .backgroundColor(Color.White)
      .borderRadius(10)
      .onContentWillChange((currentIndex, comingIndex) => {
        return true
      })
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .width('100%')
      .layoutWeight(1)

    }.width('100%')
    .backgroundColor('#eff0f4')
    .layoutWeight(1)
    .padding(10)
  }

  aboutToAppear(): void {
    let emojiGroup = this.emojiGroup[this.currentIndex]
    EmojiService.getByRepId(emojiGroup.id, (list) => {
      this.emojiList = list
    })

    // 加载所有表情
    this.emojiGroup.forEach((emojiGroupItem) => {
      let repId = emojiGroupItem.id
      EmojiService.getByRepId(repId, (list) => {
        let nullEmoji = new Emoji()
        nullEmoji.name = 'null'
        list.splice(8, 0, nullEmoji)
        this.AllEmojiList.push(list)
      })
    })
  }

  onIndexUpdate() {
    // 改变页签内容
    let emojiRep = this.emojiGroup[this.currentIndex]
  }
}