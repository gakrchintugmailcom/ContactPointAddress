public without sharing class B2B_InventoryController {
    

        @AuraEnabled
        public static List<ContactPointAddress> getContactPointAddress(Map<String, Object> dataMap) {
            String userId = UserInfo.getUserId();
            User userObj = [SELECT ContactId, AccountId FROM User WHERE Id = :userId LIMIT 1];
            return [
                SELECT Id, Name, AddressType, Country, Address, City, State,Street, PostalCode, IsDefault
                FROM ContactPointAddress
                WHERE ParentId =  :userObj.AccountId
            ];
        }
        @AuraEnabled
        public static ContactPointAddress getContactPointAddressById(Map<String, Object> dataMap) {
           
            String cpID = (String)dataMap.get('cpAddressId');
            return [
                SELECT Id, Name, AddressType, Country, Address, City, State,Street, PostalCode, IsDefault
                FROM ContactPointAddress
                WHERE Id =  :cpID
            ];
       }
       
        @AuraEnabled
        public static Map<String, Object> getBuyerInfo(Map<String, Object> dataMap) {
            String userId = UserInfo.getUserId();
            User userObj = [SELECT ContactId, AccountId FROM User WHERE Id = :userId LIMIT 1];
            Contact contactObj = [SELECT id,Name,Account.Name,Phone, Email FROM Contact where id = :userObj.ContactId];
            dataMap.put('isSuccess', true);
            dataMap.put('contactRecord', contactObj);
            return dataMap;  
        }
    
        @AuraEnabled
        public static Map<String, Object> getCartItemsById(Map<String, Object> dataMap) {
            string cartId = (String)dataMap.get('cartId');
            List<CartItem> cartItemList = [select id, Sku,Product2Id, Product2.Name,Quantity,SalesPrice,TotalAmount,CartId,Type  from CartItem WHERE CartId = :cartId];
            dataMap.put('isSuccess', true);
            dataMap.put('cartItems', cartItemList);
            return dataMap;  
        }
    
        @AuraEnabled
        public static Map<String, Object> UpdateContactPointAddress(Map<String, Object> dataMap) {
            String cpID = (String)dataMap.get('cpAddressId');
    
            ContactPointAddress  cpaRecord = [SELECT Id, Name, AddressType, Country, Address, City, State,Street, PostalCode, IsDefault
                                                FROM ContactPointAddress WHERE Id =  :cpID];
            cpaRecord.IsDefault = true;
            update cpaRecord;
            dataMap.put('isSuccess', true);
            dataMap.put('cpaRecord',cpaRecord);
            return dataMap;
        }
    
        @AuraEnabled
        public static Map<String, Object> getOrderProductSummaryById(Map<String, Object> dataMap) {
            String orderId = (String)dataMap.get('orderId');
            List<OrderItemSummary> orderedItems = [select id,OrderSummaryId, Product2.Name, StockKeepingUnit, UnitPrice, TotalLineAmount,
                                                    Quantity,Type from OrderItemSummary WHERE OrderSummaryId = :orderId];
    
            dataMap.put('isSuccess', true);
            dataMap.put('orderRecord',orderedItems);
            return dataMap;
        }
    
    
    
    
        @AuraEnabled
        public static Map<String, Object> saveNewAddress(Map<String, Object> dataMap) {
            string cartId = (string)dataMap.get('cartId');
            WebCart cartRecord = [select id,AccountId from WebCart WHERE Id = :cartId];
    
    
            if(dataMap != null && dataMap.containsKey(B2B_SetupConstants.ADDRESS) && dataMap.get(B2B_SetupConstants.ADDRESS) != null) {
                Map<Object, Object> cpaMap = (Map<Object, Object>)dataMap.get(B2B_SetupConstants.ADDRESS);
    
                ContactPointAddress cpa = new ContactPointAddress();
                cpa.AddressType = 'Shipping';
                cpa.Name = 'Shipping' + (String)cpaMap.get('City');
                cpa.Country = (String)cpaMap.get('Country');
                cpa.State = (String)cpaMap.get('State');
                cpa.Street = (String)cpaMap.get('Street');
                cpa.City = (String)cpaMap.get('City');
                cpa.PostalCode = (String)cpaMap.get('PostalCode');
                cpa.IsDefault = true;
                cpa.ParentId = cartRecord.AccountId;
                insert cpa;
                dataMap.put('isSuccess', true);
                dataMap.put('cpaRecord', cpa);
            }
            return dataMap;
        }
    
        @AuraEnabled
        public static Map<String, Object> updateCartDeliveryGroup(Map<String, Object> dataMap){
            string cartId = (string)dataMap.get('cartId');
            String cpID = (String)dataMap.get('cpAddressId');
    
            WebCart cartRecord = [select id,BillingCountry, BillingState, BillingStreet, BillingPostalCode, BillingCity from WebCart WHERE Id = :cartId];
    
    
            ContactPointAddress  cpaRecord = [SELECT Id, Name, AddressType, Country, Address, City, State,Street, PostalCode, IsDefault
                                                FROM ContactPointAddress WHERE Id =  :cpID];
    
            CartDeliveryGroup  cdgrecord = [select id,DeliverToCity, DeliverToCountry, DeliverToName, DeliverToPostalCode, DeliverToState,
                                                            DeliverToStreet ,CartId, DeliveryMethodId from CartDeliveryGroup WHERE cartId =: cartId];
    
            OrderDeliveryMethod OdmRecord =[select id from OrderDeliveryMethod];
    
            if(cpaRecord.AddressType == 'Billing'){
                cartRecord.BillingCity = cpaRecord.City;
                cartRecord.BillingCountry = cpaRecord.Country;
                cartRecord.BillingPostalCode = cpaRecord.PostalCode;
                cartRecord.BillingStreet = cpaRecord.Street;
                cartRecord.BillingState = cpaRecord.State;
    
                update cartRecord;
            }
    
            if(cpaRecord.AddressType == 'Shipping'){
                cdgrecord.DeliverToName = cpaRecord.Name;
                cdgrecord.DeliverToCity = cpaRecord.City;
                cdgrecord.DeliverToCountry = cpaRecord.Country;
                cdgrecord.DeliverToPostalCode = cpaRecord.PostalCode;
                cdgrecord.DeliverToStreet = cpaRecord.Street;
                cdgrecord.DeliverToState = cpaRecord.State;
                if( cdgrecord.DeliveryMethodId == null){
                    cdgrecord.DeliveryMethodId = OdmRecord.Id;
                }
                update cdgrecord;
            }
            dataMap.put('isSuccess', true);
            dataMap.put('cpaRecord',cpaRecord);
            dataMap.put('cartRecord',cartRecord);
            return dataMap;
        }
    
    }
    
   
    
