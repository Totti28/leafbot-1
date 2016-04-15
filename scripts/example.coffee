# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->
    start = new Date()
    trollers = [
        {
            name: "memory"
            max_health: 100
            health: 100
            spawn: start
            respawn: 60
            roar: ["!slap totti", "!gacha"]
            max_exp: 100
        },
        {
            name: "harry"
            max_health: 100
            health: 10
            spawn: start
            respawn: 60
            roar: ["我覺得可以打R", "還好吧", "ok", "廢醜窮酸魯肥宅", "我都約女生去星巴克"]
            max_exp: 5
        },
        {
            name: "k晚上"
            max_health: 100
            health: 100
            spawn: start
            respawn: 60
            roar: ["上路不用來幫", "我被gank你們快去吃龍", "我輸線就是贏game的保證","將狗都不幫QQ"]
            max_exp: 100
        },
        {
            name: "sylphwind"
            max_health: 100
            health: 100
            spawn: start
            respawn: 60
            roar: ["`>w<`", "喵", "喔"]
            max_exp: 100
        },
        {
            name: "yhsiang"
            max_health: 100
            health: 100
            spawn: start
            respawn: 60
            roar: ["哈利狗！"]
            max_exp: 100
        },
        {
            name: "smallbighead"
            max_health: 100
            health: 100
            spawn: start
            respawn: 60
            roar: ["額", "WTF", "幹！幹！幹！幹！幹！"]
            max_exp: 100
        },
        {
            name: "totti"
            max_health: 100
            health: 100
            spawn: start
            respawn: 60
            roar: ["送", "真的不是這樣", "WTF", "https://trollers.slack.com/files/leafwind/F0J7JA1GT/monkey.gif"]
            max_exp: 100
        },
        {
            name: "orinpix"
            max_health: 100
            health: 100
            spawn: start
            respawn: 60
            roar: ["你 完 蛋 了。"]
            max_exp: 100
        },
        {
            name: "DDT"
            max_health: 100
            health: 100
            spawn: start
            respawn: 60
            roar: ["你已經死了", "（揍ㄏㄌ）"]
            max_exp: 100000
        },
        {
            name: "KMT"
            max_health: 10
            health: 10
            spawn: start
            respawn: 5
            roar: ["歡迎子瑜回家", "三環三線夢裡相見", "（對台灣人民揮國旗）", "（中共來了快收國旗）", "國民黨是最團結民主的政黨", "沉默的多數站出來"]
            max_exp: 100
        },
        {
            name: "泡泡"
            max_health: 100
            health: 100
            spawn: start
            respawn: 60
            roar: ["幹嘛？叫我喔", "煩啊，衝啥？", "打屁，讓你而已", "再打ㄧ次試試看","(拿電熨斗烤土司)"]
            max_exp: 100
        }
        {
            name: "團長"
            max_health: 100
            health: 100
            spawn: start
            respawn: 60
            roar: ["嗚嗚嗚", "T_T", "=口=!!", "阿","=口=!??"]
            max_exp: 100
        }
    ]

    # key = The key by which to index the dictionary
    Array::toDict = (key) ->
        @reduce ((dict, obj) -> dict[ obj[key] ] = obj if obj[key]?; return dict), {}
    #Array::toDict = (key) ->
    #    dict = {}
    #    dict[obj[key]] = obj for obj in this when obj[key]?
    #    dict

    trollersDict = trollers.toDict('name')
    cooldown = {}
    default_cooldown = 3 # 3sec per cmd
    default_long_cooldown = 60 # a longer cooldown
    default_long_num_cmd = 10 # per 10 cmds
    # => { age: 1, name: "Bubbles" }

    # helper method to get sender of the message
    get_username = (response) ->
        "@#{response.message.user.name}"

    # helper method to get channel of originating message
    get_channel = (response) ->
        if response.message.room == response.message.user.name
            "@#{response.message.room}"
        else
            "##{response.message.room}"

    robot.hear /time/i, (res) ->
        now = new Date()
        diff = (now - start) / 1e3
        res.send "開機已經經過 #{diff} 秒。"

    robot.hear /機器人/i, (res) ->
        res.send "誰？叫我嗎？"
    
    robot.hear /寶寶/i, (res) ->
        res.send "但是寶寶不說"
    robot.respond /你好/i, (res) ->
        res.reply "你好～"

    robot.respond /閉嘴/i, (res) ->
        res.reply "你才閉嘴，你ㄊㄊ全家都閉嘴"

    check_cooldown = (username) ->
        now = new Date()
        if ! (username of cooldown)
            cooldown[username] = now
            return 0
        else
            if (now - cooldown[username]) / 1e3 > default_cooldown
                cooldown[username] = now
                return 0
            else # CDing, block
                return 1

    attack = (source, target, damage) ->
        health = trollersDict[target]["health"]
        spawn = trollersDict[target]["spawn"]
        respawn = trollersDict[target]["respawn"]
        now = new Date()
        if target in ["DDT"]
            status = "fail"
        else if target == "orinpix"
            if source of trollersDict
                trollersDict[source]["health"] = 0
                trollersDict[source]["spawn"] = now
            status = "revenge"
        else if health <= 0
            if (now - spawn) / 1e3 < respawn
                status = "dead"
            else
                trollersDict[target]["health"] = trollersDict[target]["max_health"]
                trollersDict[target]["spawn"] = now
                status = "respawned"
        else
            if trollersDict[target]["health"] - damage <= 0
                trollersDict[target]["health"] = 0
                status = "die"
            else
                trollersDict[target]["health"] -= damage
                status = "damaged"

    robot.hear /!echo (.*)/i, (res) ->
        target = res.match[1]
        quote = robot.brain.get("quote_@#{target}") ? "查無 #{target} 說過的話"
        #quote = robot.brain.get("quote_@#{target}") ? "查無 #{target} 說過的話, key = quote_#{target}"
        res.send "@#{target}：#{quote}"

    robot.hear /(.*)/i, (res) ->
        username = get_username(res)
        sentence = res.match[1]
        robot.brain.set("quote_#{username}", "#{sentence}")
        #res.send "記錄 #{username} 說過：#{sentence}, key = quote_#{username}"

    robot.hear /!(slap|punch) (.*)/i, (res) ->
        username = get_username(res)
        check_cooldown_status = check_cooldown(username)
        if check_cooldown_status == 1
            res.reply "你太多話了喔～"
            return
        target = res.match[2]
        now = new Date()
        if ! (target of trollersDict)
            res.send "你不能打 #{target}，他是無辜的。"
            return
        else
            status = attack(username, target, Math.floor(Math.random()*10))

            script = "#{target}：#{res.random trollersDict[target]["roar"]}"
            exp = "--得到 #{Math.floor(Math.random() * trollersDict[target]["max_exp"])} 點經驗值"
            health = trollersDict[target]["health"]
            spawn = trollersDict[target]["spawn"]
            respawn = trollersDict[target]["respawn"]
            if status == "fail"
                res.send "#{username} 打了 @#{target} 一巴掌。不痛不癢。" + script
            else if status == "revenge"
                res.send "#{username} 遭到 @#{target} 強力反擊而死亡。" + exp
            else if status == "dead"
                res.send "@#{target} 已死，有事燒紙" + exp
            else if status == "respawned"
                res.send "@#{target} 重生後馬上被 #{username} 賞一巴掌。" + script
                res.send "HP 剩下 #{health}"
            else if status == "die"
                res.send "@#{target} 承受不住 #{username} 這一巴掌而死去了。" + script + exp + "（重生時間 #{respawn} 秒）"
            else if status == "damaged"
                res.send "#{username} 打了 @#{target} 一巴掌。" + script + exp
                res.send "HP 剩下 #{health}。"

    robot.hear /I like pie/i, (res) ->
        res.emote "makes a freshly baked pie"

    robot.hear /!hello (.*)/i, (res) ->
        target = res.match[1]
        username = get_username(res)
        res.send "#{username} 真心的向 @#{target} 表示問候。"

    robot.hear /!layoff (.*)/i, (res) ->
        target = res.match[1]
        username = get_username(res)
        res.send "#{username} 把 @#{target} 開除了！"

    robot.hear /!gquit/i, (res) ->
        username = get_username(res)
        res.send "#{username} 離開了公會。"
    robot.hear /!gjoin/i, (res) ->
        username = get_username(res)
        res.send "#{username} 加入了公會。"
        
    robot.hear /!點頭/i, (res) ->
        username = get_username(res)
        res.send "#{username} 點了點頭。"

    robot.hear /!attack/i, (res) ->
        username = get_username(res)
        res.send "#{username} 要求大家進攻。"
    
    robot.hear /!cry/i, (res) ->
        username = get_username(res)
        res.send "#{username} 哭了。"

    robot.hear /!agree/i, (res) ->
        username = get_username(res)
        res.send "#{username} 同意這個觀點。"
    robot.hear /!burp/i, (res) ->
        username = get_username(res)
        res.send "#{username} 打了一個嗝。"
    robot.hear /!eat/i, (res) ->
        username = get_username(res)
        res.send "#{username} 開始吃東西。"
    robot.hear /!in/i, (res) ->
        username = get_username(res)
        res.send "#{username} 硬了。"
    robot.hear /!cold/i, (res) ->
        username = get_username(res)
        res.send "#{username} 覺得很冷。"
    robot.hear /!graduate/i, (res) ->
        username = get_username(res)
        res.send "#{username} 畢業了！"
    robot.hear /!hot/i, (res) ->
        username = get_username(res)
        res.send "#{username} 覺得很熱！"
    robot.hear /!strong/i, (res) ->
        username = get_username(res)
        res.send "#{username} 展示了自己的肌肉。好壯阿！"
    robot.hear /!flirt (.*)/i, (res) ->
        target = res.match[1]
        username = get_username(res)
        res.send "#{username} 開始跟 @#{target} 調情。"
    robot.hear /!搖頭/i, (res) ->
        username = get_username(res)
        res.send "#{username} 搖了搖頭。"
    robot.hear /!dance/i, (res) ->
        username = get_username(res)
        res.send "#{username} 開始跳舞。"
    robot.hear /!clap/i, (res) ->
        username = get_username(res)
        res.send "#{username} 激動地鼓掌。"
    robot.topic (res) ->
        res.send "#{res.message.text}? 聽起來很有趣！"

    robot.hear /!hungry (.*)/i, (res) ->
        target = res.match[1]
        username = get_username(res)
        res.send "#{username} 感到很餓，也許在 @#{target} 那裏可以找到一些食物。"
    robot.hear /!bonk (.*)/i, (res) ->
        target = res.match[1]
        username = get_username(res)
        res.send "#{username} 重重的敲了 @#{target} 的腦袋，發出「咚」的一聲。"
    robot.hear /!drink/i, (res) ->
        username = get_username(res)
        res.send "#{username} 開始喝東西。"    
   
          
     robot.hear /!trade (.*)/i, (res) ->
         target = res.match[1]
         username = get_username(res)
         res.send "#{username} 跟 @#{target} 提出交易的要求。"
     robot.hear /!deal (.*)/i, (res) ->
         target = res.match[1]
         username = get_username(res)
         res.send "#{username} 同意了跟 @#{target} 的交易。"    
     robot.hear /!nodeal (.*)/i, (res) ->
         target = res.match[1]
         username = get_username(res)
         res.send "#{username} 否決了跟 @#{target} 的交易。"    
      
     robot.hear /!下班/i, (res) ->
         username = get_username(res)
         res.send "#{username} 下班了。"    
    enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
    leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
    robot.enter (res) ->
        res.send res.random enterReplies
    robot.leave (res) ->
        res.send res.random leaveReplies

    robot.error (err, res) ->
        robot.logger.error "DOES NOT COMPUTE"
        if res?
            res.reply "DOES NOT COMPUTE"

  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  #
    robot.respond /have a soda/i, (res) ->
        # Get number of sodas had (coerced to a number).
        sodasHad = robot.brain.get('totalSodas') * 1 or 0

        if sodasHad > 4
            res.reply "I'm too fizzy.."

        else
            res.reply 'Sure!'

            robot.brain.set 'totalSodas', sodasHad+1

    robot.respond /sleep it off/i, (res) ->
        robot.brain.set 'totalSodas', 0
        res.reply 'zzzzz'
