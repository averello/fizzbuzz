//
//  Created by Georges Boumis on 18/2/20.
//  Copyright © 2020 Georges Boumis. All rights reserved.
//

import Foundation

/*:
 # FizzBuzz in Swift by Embedding a Domain-Specific Language
 [source](https://themonadreader.files.wordpress.com/2014/04/fizzbuzz.pdf)
 */

/*:
 ## Fizzbuzz examples
 */

print("## STRUCTURES ##")
for i in (1...20) {
    let s = "\(i)"
    print(Structures.fizzBuzz(s))

}

print("## DIRECT ##")
for i in (1...20) {
    print(Direct.fizzbuzz(i))
}

print("## INLINE ##")
for i in (1...20) {
    print(Typealias.fizzBuzz(i))
}


