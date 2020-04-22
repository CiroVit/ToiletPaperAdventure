

import SpriteKit
import UIKit

struct PhysicsCategory {
    static let none       : UInt32 = 0
    static let all        : UInt32 = UInt32.max
    static let monster    : UInt32 = 0b1       // 1
    static let projectile : UInt32 = 0b10      // 2
    static let player     : UInt32 = 0b11
    static let invincibilityMask : UInt32 = 0b01
    static let projectile2 : UInt32 = 0b11
    
}


func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}





class GameScene: SKScene{
    
    
    
    private var walkingPlayerFrames : [SKTexture] = []
    var player = SKSpriteNode()
    var scoreLabel = SKLabelNode()
    var ScoreInteger = 0
    var JumpEnded = true
    var LifeCounter = 3
    weak var viewController : UIViewController?
    let heart1 = SKSpriteNode(imageNamed: "hearth")
    let heart2 = SKSpriteNode(imageNamed: "hearth")
    let heart3 = SKSpriteNode(imageNamed: "hearth")
    var counter = 0
    var gameStateIsInGame = true
    var minute = 0
    var gameSpeed:CGFloat = 0.5
    var maxSpeed: Double = 0.0
    var minSpawnMonster:Double = 2.0
    var maxSpawnMonster:Double = 17.0
    var previousScore = 20
    var speedScore = 20
    private var invincibile = false
//    proiettili
    var siringa = true
    var pizza = false
    var sanitizer = false
   
   
//    points based on time
    override func update(_ currentTime: TimeInterval) {
        
        timeScore()
    }
    
    
    
//    func ConfigureSpeed(){
//        let movementSpeed = SKAction.speed(by: gameSpeed, duration: 0)
//        run(movementSpeed)
//    }
    
    override func didMove(to view: SKView) {
        
        
        
        //1
        heart1.position = CGPoint(x: frame.minX+heart1.frame.width, y: frame.maxY-30)
        heart2.position = CGPoint(x: heart1.position.x+heart2.size.width+5, y: frame.maxY-30)
        heart3.position = CGPoint(x: heart2.position.x+heart1.size.width+5, y: frame.maxY-30)
        addChild(heart1)
        addChild(heart2)
        addChild(heart3)
        
        
        //2
        
        createBackground()
        createScore()
//        createSky()
//        createGround()
        
        // 3
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addInvincibilityMask),
                SKAction.wait(forDuration: TimeInterval(random(min : 1, max: 55)))
            ])
            ))
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: TimeInterval(random(min : CGFloat(minSpawnMonster), max: CGFloat(maxSpawnMonster))))

            ])
        ))
        
        
        run(SKAction.repeatForever(
            
            SKAction.sequence([
                SKAction.run(addToiletPaper),
                SKAction.wait(forDuration: TimeInterval(random(min : CGFloat(minSpawnMonster), max: CGFloat(maxSpawnMonster))))

            ])
        ))
        
        run(SKAction.repeatForever(
        SKAction.sequence([
            SKAction.run(AddCoin),
            SKAction.wait(forDuration: TimeInterval(random(min : 1, max: 10)))
        ])
        ))
        
        
        //4
        
        physicsWorld.gravity = .init(dx: 0, dy: -1)
        physicsWorld.contactDelegate = self
        buildPlayer()
        animatePlayer()
        timeScore()
        
        
//        animatePlayer()
        
        
        
        /* Qui inizializzo la Musica*/
        //        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        //        backgroundMusic.autoplayLooped = true
        //        addChild(backgroundMusic)
    }
    
    func timeScore(){
        if gameStateIsInGame == true {
                if counter >= 60{
                ScoreInteger = ScoreInteger + 1
                counter = 0
                     self.scoreLabel.text = "SCORE : \(self.ScoreInteger)"
                    DispatchQueue.main.async {
                               self.scoreLabel.text = "SCORE : \(self.ScoreInteger)"
                           }
                           changeSpeed()
                } else{
                    counter = counter + 1
                }
        }
        }
    
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 24
        
        scoreLabel.position = CGPoint(x: frame.maxX-100, y: frame.maxY - 30)
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontColor = UIColor.black
        
        addChild(scoreLabel)
    }

    
    func changeSpeed(){
       if maxSpeed <= 16.0 {
    if ScoreInteger >= previousScore + 200 {
                           gameSpeed += 0.1
                           maxSpeed += 0.5
                    previousScore = ScoreInteger
                       print("SPEED\(self.gameSpeed)")
                       print("MAX\(self.maxSpeed)")
        minSpawnMonster += 0.2
        maxSpawnMonster -= 0.2
                            
                           }
                           
                       }
                   }
               
    
    
    func buildPlayer(){
        let playerAnimatedAtlas = SKTextureAtlas(named: "Pixeldoctor")
        var walkFrames : [SKTexture] = []
        let numImages = playerAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let playerTextureName = "doc\(i)"
            walkFrames.append(playerAnimatedAtlas.textureNamed(playerTextureName))
        }
        walkingPlayerFrames = walkFrames
        let firstFrameTexture = walkingPlayerFrames[0]
        player = SKSpriteNode(texture: firstFrameTexture)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true // 2
        player.physicsBody?.categoryBitMask = PhysicsCategory.player // 3
        player.physicsBody?.contactTestBitMask = PhysicsCategory.monster // 4
        player.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        player.physicsBody?.affectedByGravity = false
        player.zPosition = -5
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.25)
        player.setScale(0.10)
        // 4
        addChild(player)
        
    }
    func animatePlayer(){
        player.run(SKAction.repeatForever(
            SKAction.animate(with: walkingPlayerFrames,
                             timePerFrame: 0.2,
                             resize: false,
                             restore: true)
        ), withKey: "walkInPlacePlayer")
    }
    
    
//    func createSky() {
//        let topSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.77, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.67))
//        topSky.anchorPoint = CGPoint(x: 0.5, y: 1)
//
//        let bottomSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.16, brightness: 0.76, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.33))
//        bottomSky.anchorPoint = CGPoint(x: 0.5, y: 1)
//
//        topSky.position = CGPoint(x: frame.midX, y: frame.height)
//        bottomSky.position = CGPoint(x: frame.midX, y: bottomSky.frame.height)
//
//        addChild(topSky)
//        addChild(bottomSky)
//
//        bottomSky.zPosition = -40
//        topSky.zPosition = -40
//    }
//
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF )
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    
    
    
    func addMonster() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "virus")
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
        monster.physicsBody?.node?.name = "monster"
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
       
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        // Add the monster to the scene
        
        monster.speed = gameSpeed
        // Determine speed of the monster
//        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY),
                                       duration: TimeInterval(1))
        
        //        let loseAction = SKAction.run() { [weak self] in
        //            guard let `self` = self else { return }
        //            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        //            let gameOverScene = GameOverScene(size: self.size, won: false)
        //            self.view?.presentScene(gameOverScene, transition: reveal)
        //        }
        
        
        let actionMoveDone = SKAction.removeFromParent()
        
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
        addChild(monster)
    }
    
    
    func addToiletPaper() {
        let toiletPaper = SKSpriteNode(imageNamed: "toiletPaper")
        toiletPaper.physicsBody = SKPhysicsBody(rectangleOf: toiletPaper.size) // 1
        toiletPaper.physicsBody?.isDynamic = true // 2
        toiletPaper.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
        toiletPaper.physicsBody?.node?.name = "toiletPaper"
        toiletPaper.physicsBody?.contactTestBitMask = PhysicsCategory.player // 4
        toiletPaper.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        
        toiletPaper.position = CGPoint(x: size.width + toiletPaper.size.width/2, y: toiletPaper.size.height/2+20)
        toiletPaper.speed = gameSpeed
        
        
        
        let actionMove = SKAction.move(to: CGPoint(x: -toiletPaper.size.width/2, y:toiletPaper.size.height/2+20),
                                       duration: TimeInterval(1))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        toiletPaper.run(SKAction.sequence([actionMove, actionMoveDone]))
        addChild(toiletPaper)
    }
    
    func addInvincibilityMask() {
        let invincibilityMask = SKSpriteNode(imageNamed: "mask")
        invincibilityMask.physicsBody = SKPhysicsBody(rectangleOf: invincibilityMask.size)
        invincibilityMask.physicsBody?.isDynamic = true
        invincibilityMask.physicsBody?.categoryBitMask = PhysicsCategory.invincibilityMask
        invincibilityMask.physicsBody?.node?.name = "invincibilityMask"
        invincibilityMask.physicsBody?.contactTestBitMask = PhysicsCategory.player // 4
        invincibilityMask.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        let actualY = random(min: invincibilityMask.size.height/2, max: player.size.height + 50 )
        invincibilityMask.position = CGPoint(x: size.width + invincibilityMask.size.width/2, y: actualY)
        invincibilityMask.speed = 1
        let actionMove = SKAction.move(to: CGPoint(x: -invincibilityMask.size.width/2, y: actualY),
                                              duration: TimeInterval(1))
        let actionMoveDone = SKAction.removeFromParent()
        invincibilityMask.run(SKAction.sequence([actionMove, actionMoveDone]))
               addChild(invincibilityMask)
        
    }
//    add proiettili
//    siringa
    func AddSiringe() {
        let siringe = SKSpriteNode(imageNamed: "siringe")
        siringe.physicsBody = SKPhysicsBody(rectangleOf: siringe.size)
//        siringe.physicsBody?.isDynamic = true
        siringe.physicsBody?.categoryBitMask = PhysicsCategory.invincibilityMask
        siringe.physicsBody?.node?.name = "siringe"
        siringe.physicsBody?.contactTestBitMask = PhysicsCategory.player // 4
        siringe.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        siringe.setScale(0.025)
        siringe.physicsBody?.affectedByGravity = true
        let fall = SKAction.moveTo(y: siringe.frame.height/2 , duration: 0.01 )
        let waitTheFall = SKAction.wait(forDuration: 0.02)
        let actualY = random(min: siringe.size.height/2, max: size.height - siringe.size.height/2)
        siringe.position = CGPoint(x: size.width + siringe.size.width/2, y: actualY)
        siringe.speed = 1
        let actionMove = SKAction.move(to: CGPoint(x: -siringe.size.width/2, y: actualY),
                                              duration: TimeInterval(1))
        let actionMoveDone = SKAction.removeFromParent()
        siringe.run(SKAction.sequence([fall,waitTheFall,actionMove, actionMoveDone]))
               addChild(siringe)
        }
//    pizza
    func AddPizza() {
        let pizza = SKSpriteNode(imageNamed: "pizza")
        pizza.physicsBody = SKPhysicsBody(rectangleOf: pizza.size)
//        pizza.physicsBody?.isDynamic = true
        pizza.physicsBody?.categoryBitMask = PhysicsCategory.projectile2
        pizza.physicsBody?.node?.name = "pizza"
        pizza.physicsBody?.contactTestBitMask = PhysicsCategory.player // 4
        pizza.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        pizza.setScale(0.025)
        pizza.physicsBody?.affectedByGravity = true
        let fall = SKAction.moveTo(y: self.frame.height, duration: 0.08)
        let waitTheFall = SKAction.wait(forDuration: 0.08)
        let actualY = random(min: pizza.size.height/2, max: size.height - pizza.size.height/2)
        pizza.position = CGPoint(x: size.width + pizza.size.width/2, y: actualY)
        pizza.speed = 1
        let actionMove = SKAction.move(to: CGPoint(x: -pizza.size.width/2, y: actualY),
                                              duration: TimeInterval(1))
        let actionMoveDone = SKAction.removeFromParent()
        pizza.run(SKAction.sequence([fall,waitTheFall,actionMove, actionMoveDone]))
               addChild(pizza)
    }
//    sanitizer
    func AddSanitizer() {
        let sanitizer = SKSpriteNode(imageNamed: "sanitizer")
        sanitizer.physicsBody = SKPhysicsBody(rectangleOf: sanitizer.size)
//        sanitizer.physicsBody?.isDynamic = true
        sanitizer.physicsBody?.categoryBitMask = PhysicsCategory.projectile2
        sanitizer.physicsBody?.node?.name = "sanitizer"
        sanitizer.physicsBody?.contactTestBitMask = PhysicsCategory.player // 4
        sanitizer.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        sanitizer.setScale(0.025)
        sanitizer.physicsBody?.affectedByGravity = true
        let fall = SKAction.moveTo(y: self.frame.height , duration: 0.08)
        let waitTheFall = SKAction.wait(forDuration: 0.08)
        let actualY = random(min: sanitizer.size.height/2, max: size.height - sanitizer.size.height/2)
        sanitizer.position = CGPoint(x: size.width + sanitizer.size.width/2, y: actualY)
        sanitizer.speed = 0.6
        let actionMove = SKAction.move(to: CGPoint(x: -sanitizer.size.width/2, y: actualY),
                                              duration: TimeInterval(1))
        let actionMoveDone = SKAction.removeFromParent()
        sanitizer.run(SKAction.sequence([fall,waitTheFall,actionMove, actionMoveDone]))
               addChild(sanitizer)
    }
    
    func AddCoin() {
         let coin = SKSpriteNode(imageNamed: "coin")
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        //        sanitizer.physicsBody?.isDynamic = true
                coin.physicsBody?.categoryBitMask = PhysicsCategory.projectile2
                coin.physicsBody?.node?.name = "coin"
                coin.physicsBody?.contactTestBitMask = PhysicsCategory.player // 4
                coin.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
                coin.setScale(0.065)
                coin.physicsBody?.affectedByGravity = true
                let actualY = random(min: coin.size.height/2, max: size.height - player.size.height)
                coin.position = CGPoint(x: size.width + coin.size.width/2, y: actualY)
        coin.speed = 0.8
                let actionMove = SKAction.move(to: CGPoint(x: -coin.size.width/2, y: actualY),
                                                      duration: TimeInterval(1))
                let actionMoveDone = SKAction.removeFromParent()
                coin.run(SKAction.sequence([actionMove, actionMoveDone]))
                       addChild(coin)
    }
    
    
    
    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "hospital")
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.zPosition = -30
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat(1 * i), y: 0)
            addChild(background)
            let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 10)
            let moveReset = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
        
            background.run(moveForever)
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        let toiletPaper = SKSpriteNode(imageNamed: "toiletPaper")
        if  touchLocation.x < 400 && JumpEnded == true && touchLocation.y < 400{
            // 2 - Set up initial location of projectile
            JumpEnded = false
            let jumpUpAction = SKAction.moveBy(x: 0, y: toiletPaper.size.height+80 ,duration:0.3)
            // move down 20
            let jumpDownAction = SKAction.moveBy(x: 0, y: -toiletPaper.size.height-80,duration:0.4)
            // sequence of move yup then down
            let EndJump = SKAction.run {
                self.JumpEnded = true
            }
            let jumpSequence = SKAction.sequence([jumpUpAction, jumpDownAction, EndJump])
            
            // make player run sequence
            
            player.run(jumpSequence)
            
        }
        else {
                   
                   //            run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
            var projectile = SKSpriteNode(imageNamed: "siringe")
            if siringa == true {
                projectile = SKSpriteNode(imageNamed: "siringe")
                projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
                                  projectile.physicsBody?.isDynamic = true
                                  projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
                                  projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
                                  projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
                                  projectile.physicsBody?.usesPreciseCollisionDetection = true
                                  projectile.setScale(0.025)
                projectile.zRotation = .pi / -2
            }
            if pizza == true {
                projectile = SKSpriteNode(imageNamed: "pizza")
                projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
                                  projectile.physicsBody?.isDynamic = true
                                  projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
                                  projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
                                  projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
                                  projectile.physicsBody?.usesPreciseCollisionDetection = true
                                  projectile.setScale(0.03)
            }
            if sanitizer == true {
                projectile = SKSpriteNode(imageNamed: "sanitizer")
                projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
                                  projectile.physicsBody?.isDynamic = true
                                  projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
                                  projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
                                  projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
                                  projectile.physicsBody?.usesPreciseCollisionDetection = true
                                  projectile.setScale(0.015)
            }
                  
                   projectile.position = player.position
                   
                   // 3 - Determine offset of location to projectile
                   let offset = touchLocation - projectile.position
                   
                   // 4 - Bail out if you are shooting down or backwards
                   if offset.x < 0 { return }
                   
                   // 5 - OK to add now - you've DispatchQueue.main.async {
                   addChild(projectile)
                   
                   // 6 - Get the direction of where to shoot
                   let direction = offset.normalized()
                   
                   // 7 - Make it shoot far enough to be guaranteed off screen
                   let shootAmount = direction * 750
                   
                   // 8 - Add the shoot amount to the current position
                   let realDest = shootAmount + projectile.position
                   
                   // 9 - Create the actions
                   let actionMove = SKAction.move(to: realDest, duration: 1.8)
                   let actionMoveDone = SKAction.removeFromParent()
                   projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
                   
                   
               }
        
    }
    func randomWeaponSpawn(position: CGPoint) {
        switch (random(min : 1, max: 15)) {

           case 0:
                
               AddSiringe()
               

           case 1:

               AddPizza()

           case 2:

               AddSanitizer()

           default:
               return
           }

    
    }
    
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        
//        proiettili
//        siringa
        if projectile == player && monster.physicsBody?.node!.name == "siringe" {
            if siringa != true {
                siringa = true
                pizza = false
                sanitizer = false
            }
        }
//        pizza
        if projectile == player && monster.physicsBody?.node!.name == "pizza" {
            if pizza != true {
                siringa = false
                pizza = true
                sanitizer = false
          }
        }
//        sanitizer
        if projectile == player && monster.physicsBody?.node!.name == "sanitizer" {
            if sanitizer != true {
                siringa = false
                pizza = false
                sanitizer = true
          }
        }
        
//        raccogli monete
        if projectile == player && monster.physicsBody?.node!.name == "coin" {
            monster.removeFromParent()
            ScoreInteger += 5
            DispatchQueue.main.async {
                self.scoreLabel.text = "SCORE : \(self.ScoreInteger)"
            }
            changeSpeed()
        }
        
//        invincibilità
        if projectile == player && monster.physicsBody?.node!.name == "invincibilityMask" {
                invincibile = true
                let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
                let fadeInAction = SKAction.fadeIn(withDuration: 0.5)
            let fadeOutIn = SKAction.sequence([fadeOutAction,fadeInAction])
                let fadeOutInAction = SKAction.repeat(fadeOutIn, count: 5)
                let waitForNextAction = SKAction.wait(forDuration: TimeInterval(2.1))
           
                let setInvicibleFalse = SKAction.run(){
                    self.invincibile = false
            }
                let sequence = SKAction.sequence([fadeOutInAction,waitForNextAction,setInvicibleFalse])
            ScoreInteger += 20
            player.run(sequence)
            print("invincibility")
            monster.removeFromParent()
            
        }
        
        if projectile != player && monster.physicsBody?.node?.name == "monster" {
            
            if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") {
                print("esplosione")
                explosion.position = monster.position
                addChild(explosion)
                randomWeaponSpawn(position: monster.position)
            }
            
            ScoreInteger += 10
            changeSpeed()
            DispatchQueue.main.async {
                self.scoreLabel.text = "SCORE : \(self.ScoreInteger)"
            }
            print("Hit")
            projectile.removeFromParent()
            monster.removeFromParent()
        }
            
        else if projectile == player && monster.physicsBody?.node!.name == "toiletPaper" {
            print("Player hitted by \(String(describing: monster.physicsBody?.node?.name))")
            
            switch LifeCounter {
            case 1 :
                if invincibile == false{
                self.heart3.removeFromParent()
                let loseAction = SKAction.run() { [weak self] in
                    guard let `self` = self else { return }
                    let reveal = SKTransition.push(with: .down, duration: 0.5)
                    let gameOverScene = GameOverScene(size: self.size, won: false)
                    
                    
                    self.view?.presentScene(gameOverScene, transition: reveal)
                    }
                if ScoreInteger > defaults.integer(forKey: "Score") {
                    defaults.set(ScoreInteger, forKey: "Score")
                    
                }
                
                player.run(loseAction)
                }
                else {
                    monster.removeFromParent()
                }
                
                //                viewController?.performSegue(withIdentifier: "Lose", sender: self)
                
                
                break
            case 2 :
                    if invincibile == false{
                self.heart2.removeFromParent()
                LifeCounter -= 1
                    } else {
                        monster.removeFromParent()
                    }
            case 3 :
                    if invincibile == false{
                self.heart1.removeFromParent()
                LifeCounter -= 1
                } else {
                    monster.removeFromParent()
                }
            default :
                print("NO LIFE")
            }
            monster.removeFromParent()
        }
            
            
        else if projectile == player && monster.physicsBody?.node!.name == "monster" {
            print("Player hitted by \(String(describing: monster.physicsBody?.node?.name))")
            
            switch LifeCounter {
            case 1 :
                if invincibile == false{
                self.heart3.removeFromParent()
                let loseAction = SKAction.run() { [weak self] in
                    guard let `self` = self else { return }
                    let reveal = SKTransition.push(with: .down, duration: 0.5)
                    let gameOverScene = GameOverScene(size: self.size, won: false)
                    
                    self.view?.presentScene(gameOverScene, transition: reveal)
                    
                }
                if ScoreInteger > defaults.integer(forKey: "Score") {
                    defaults.set(ScoreInteger, forKey: "Score")
                    
                }
                
                
                
                player.run(loseAction)
                
                //                viewController?.performSegue(withIdentifier: "Lose", sender: self)
                }
                else {
                    monster.removeFromParent()
                }
                
                break
            case 2 :
                if invincibile == false{
                self.heart2.removeFromParent()
                LifeCounter -= 1
            }else {
                monster.removeFromParent()
            }
            case 3 :
                if invincibile == false{
                self.heart1.removeFromParent()
                LifeCounter -= 1
        }else {
            monster.removeFromParent()
        }
            default :
                print("NO LIFE")
            }
            monster.removeFromParent()
            
        }
    }
}



extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode,
                let projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }

    }
}


