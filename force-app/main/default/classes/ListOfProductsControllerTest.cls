@isTest
public with sharing class ListOfProductsControllerTest {
	@TestSetup
	static void makeData() {
		List<SObject> testData = new List<SObject>();
		Product_Table__c product = new Product_Table__c(
			Name = 'M. Shelly "Frankenstein"',
			Product_Description__c = 'On the surface, it is a novel of tense and steadily mounting horror.',
			Image_Url__c = 'https://images-na.ssl-images-amazon.com/images/I/91%2BkeCUpW3L.jpg'
		);
		testData.add(product);
		insert testData;
	}
	@isTest 
	public static void testListofProductsController() {
		List<Product_Table__c> productList = [
			SELECT Id
			FROM Product_Table__c
		];
		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(productList);
		ListOfProductsController listOfProducts = new ListOfProductsController(stdSetController);
		listOfProducts.currentProductId = productList[0].Id;
		PageReference orderProductTablePage = Page.OrderDetailedPage;
		orderProductTablePage.getParameters().put('Id', productList[0].Id);
		PageReference detailProductPage = Page.ProductDetailedPage;
		detailProductPage.getParameters().put('Id', productList[0].Id);

		Test.startTest();
		Pagereference orderProductPage = listOfProducts.goToOrderDetailedPage();
		Pagereference detailPage = listOfProducts.goToProductDetailedPage();
		Test.stopTest();

		System.assertEquals(orderProductTablePage.getUrl(), orderProductPage.getUrl());
		System.assertEquals(detailProductPage.getUrl(), detailPage.getUrl());
	}
}