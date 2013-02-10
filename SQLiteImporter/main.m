//
//  main.m
//  SQLiteImporter
//
//  Created by Richard Geier on 8/5/12.
//  Copyright (c) 2012 Richard Geier. All rights reserved.
//

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = @"testApp";
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = [[NSProcessInfo processInfo] arguments][0];
        path = [path stringByDeletingPathExtension];
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        // Create the managed object context
        NSManagedObjectContext *context = managedObjectContext();
        
        // Custom code here...
        
        // Start of Region Import Method
        //================================================================================================
        NSError* regionErr = nil;
        NSString* regionDataPath = [[NSBundle mainBundle] pathForResource:@"Regions" ofType:@"json"];
        NSArray* Regions = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:regionDataPath]
                                                         options:kNilOptions
                                                           error:&regionErr];
        NSLog(@"Imported Regions: %@", Regions);
        
        [Regions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSManagedObject *regionInfo = [NSEntityDescription
                                              insertNewObjectForEntityForName:@"Region"
                                              inManagedObjectContext:context];
            [regionInfo setValue:[obj objectForKey:@"attractionCount"] forKey:@"attractionCount"];
            [regionInfo setValue:[obj objectForKey:@"regionCity"] forKey:@"regionCity"];
            [regionInfo setValue:[obj objectForKey:@"regionLatitude"] forKey:@"regionLatitude"];
            [regionInfo setValue:[obj objectForKey:@"regionLongitude"] forKey:@"regionLongitude"];
            [regionInfo setValue:[obj objectForKey:@"regionOverviewText"] forKey:@"regionOverviewText"];
            [regionInfo setValue:[obj objectForKey:@"regionState"] forKey:@"regionState"];
            [regionInfo setValue:[obj objectForKey:@"regionTitle"] forKey:@"regionTitle"];
            [regionInfo setValue:[obj objectForKey:@"regionZipcode"] forKey:@"regionZipcode"];
         
             
            NSError *regionError;
            if (![context save:&regionError]) {
                NSLog(@"Whoops, couldn't save: %@", [regionError localizedDescription]);
            }
        }];
        
        // Test listing all Regions from the store
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Region"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"regionCity = %@",entity];
        //[fetchRequest setPredicate:predicate];
        NSError *regionErrorFinal = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&regionErrorFinal];
        NSLog(@"<---------These Regions were added--------->");
        for (NSManagedObject *info in fetchedObjects) {
            NSLog(@"Name: %@", [info valueForKey:@"regionTitle"]);
        }
        // End of Region Import Method
        //================================================================================================
        
        
        // Start of Attraction Import  Method
        //================================================================================================
        NSError* attractionErr = nil;
        NSString* attractionDataPath = [[NSBundle mainBundle] pathForResource:@"Attractions" ofType:@"json"];
        NSData* data = [NSData dataWithContentsOfFile:attractionDataPath];
        NSArray* Attractions = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&attractionErr];
        NSLog(@"Whoops, couldn't save: %@", [attractionErr localizedDescription]);
    
        NSLog(@"Imported Attractions: %@", Attractions);
        
        [Attractions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSManagedObject *attractionInfo = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"Attraction"
                                           inManagedObjectContext:context];
            [attractionInfo setValue:[obj objectForKey:@"attractionType"] forKey:@"attractionType"];
            [attractionInfo setValue:[obj objectForKey:@"attractionLatitude"] forKey:@"attractionLatitude"];
            [attractionInfo setValue:[obj objectForKey:@"attractionLongitude"] forKey:@"attractionLongitude"];
            [attractionInfo setValue:[obj objectForKey:@"attractionCity"] forKey:@"attractionCity"];
            [attractionInfo setValue:[obj objectForKey:@"attractionOverviewText"] forKey:@"attractionOverviewText"];
            [attractionInfo setValue:[obj objectForKey:@"attractionState"] forKey:@"attractionState"];
            [attractionInfo setValue:[obj objectForKey:@"attractionTitle"] forKey:@"attractionTitle"];
            [attractionInfo setValue:[obj objectForKey:@"attractionZipcode"] forKey:@"attractionZipcode"];
            //[attractionInfo setValue:[obj objectForKey:@"region"] forKey:@"region"];
            
            
            NSError *AttractionError;
            if (![context save:&AttractionError]) {
                NSLog(@"Whoops, couldn't save: %@", [AttractionError localizedDescription]);
            }
        }];
        
        // Test listing all Attractions from the store
        fetchRequest = [[NSFetchRequest alloc] init];
        entity = [NSEntityDescription entityForName:@"Attraction"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSError *AttractionErrorFinal = nil;
        fetchedObjects = [context executeFetchRequest:fetchRequest error:&AttractionErrorFinal];
        NSLog(@"<---------These Attractions were added--------->");
        for (NSManagedObject *info in fetchedObjects) {
            NSLog(@"Name: %@", [info valueForKey:@"attractionTitle"]);
        }
        // End of Attraction Import Method
        //================================================================================================
        
    }
    return 0;
}

