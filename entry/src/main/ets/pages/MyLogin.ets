/**
 * @Auhtor DLY
 *
 */
import { AuthMode, Login } from '@hw-agconnect/auth-component'
import cloud, { AuthUser } from '@hw-agconnect/cloud'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct MyLogin {
  build() {
    Column({space:20}) {
      Text('系统登录')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
      /**
       * 手机+验证码登录
       */
      Login({
        modes:[AuthMode.PHONE_VERIFY_CODE],
        onSuccess:(user:AuthUser)=>{
        AppStorage.setOrCreate('user',user)
        router.replaceUrl({url:'pages/home/Index'})
      }
      }){
        Button('手机+验证码登录')
          .width('80%')
      }

      /**
       * 邮箱+验证码
       */
      Login({
        modes:[AuthMode.MAIL_VERIFY_CODE],
        onSuccess:(user:AuthUser)=>{
          AppStorage.setOrCreate('user',user)
          router.replaceUrl({url:'pages/home/Index'})
      }
      }){
        Button('邮箱+验证码登录')
          .width('80%')
      }


      /**
       * 邮箱+密码
       */
      Login({
        modes:[AuthMode.PASSWORD],
        onSuccess:(user:AuthUser)=>{
          AppStorage.setOrCreate('user',user)
          router.replaceUrl({url:'pages/home/Index'})
        }
      }){
        Button('邮箱+密码登录')
          .width('80%')
      }


      /**
       * 邮箱+验证码
       */
      // Login({
      //   modes:[AuthMode.MAIL_VERIFY_CODE,AuthMode.PASSWORD,AuthMode.PHONE_VERIFY_CODE],
      //   onSuccess:(user:AuthUser)=>{
      //     AppStorage.setOrCreate('user',user)
      //     router.replaceUrl({url:'pages/home/Index'})
      //   }
      // }){
      //   Button('登录')
      //     .width('80%')
      // }



    }
    .width('100%')
    .height('100%')

    
  }
}