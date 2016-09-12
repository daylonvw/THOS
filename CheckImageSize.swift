//
//  CheckImageSize.swift
//  THOS
//
//  Created by daylonvanwel on 12-09-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import Foundation

func checkImageSizeForUpload(image: UIImage) -> Bool {
    
    let imageData = UIImageJPEGRepresentation(image, 1.0)
    
    let dataSize = (imageData?.length)! / 1000000
    
    
    if dataSize < 10 {
        
        return true
        
    } else {
        
        return false

    }
}


//func shrinkImage(image: UIImage, compression: CGFloat) {
//    
//    let imageData = UIImageJPEGRepresentation(image, self.compressionFloat)
//    let newImage = UIImage(data: imageData!)
//    
//    print(imageData?.length)
//    
//    self.checkImageSize(newImage!)
//}

//func upDatePortfolioWithImage(image: UIImage) {
//    
//    self.compressionFloat = 1.0
//    
//    let imageData = UIImageJPEGRepresentation(image, 1.0)
//    
//    portfolio.append(image)
//    self.portfoliaCollectionView.reloadData()
//    
//    let imageFile = PFFile(data: imageData!)
//    
//    let imageObject = PFObject(className: "Portfolio")
//    imageObject["user"] = PFUser.currentUser()
//    imageObject["image"] = imageFile
//    
//    imageObject.saveInBackgroundWithBlock { (succeded, error) in
//        
//        if error != nil {
//            
//            print(error?.localizedDescription)
//            
//        } else {
//            
//            if succeded == true {
//                
//            }
//        }
//    }
//    
//}