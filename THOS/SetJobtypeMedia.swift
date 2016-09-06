//
//  SetJobtypeMedia.swift
//  THOS
//
//  Created by daylonvanwel on 06-09-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import Foundation


func getJotTypeMedia(type: NSNumber, subtype: NSNumber) -> (UIImage, String) {
    
    if type == 0 {
        
        if subtype == 0 {
            
            return  (UIImage(named: "IndoorCleaning")!,"Schoonmaak" )
            
        } else if subtype == 1 {
            
            return (UIImage(named: "nanny")!,"Oppas")
            
        } else if subtype == 2 {
            
            return  (UIImage(named: "woodWork")!, "Houtwerk")
            
        } else if subtype == 3 {
            
            return (UIImage(named: "electrician")!, "Electricien")
            
        } else {
            
            return (UIImage(), "")
        }
        
    } else if type == 1 {
        
        if subtype == 0 {
            
            return (UIImage(named: "aroundTheHouse")!,"Rondom het huis")
            
        } else if subtype == 1 {
            
            return (UIImage(named: "garden")!, "In de tuin")
            
        } else {
            
            return (UIImage(),"")
        }
        
    } else if type == 2 {
        
        return (UIImage(named: "pickUp")!, "Vervoer en verzend")
        
    } else {
        
        return (UIImage(),"")
    }
    
}
