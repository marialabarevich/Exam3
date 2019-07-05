@isTest
public with sharing class ProductDetailedPageControllerTest {
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
	public static void testProductDetailedPageController() {
		List<Product_Table__c> productList = [
			SELECT Id
			FROM Product_Table__c
		];
		ApexPages.StandardController stdController = new ApexPages.StandardController(productList[0]);
		ProductDetailedPageController productTableController = new ProductDetailedPageController(stdController);
		productTableController.currentProductId = productList[0].Id;
		PageReference orderProductTablePage = Page.OrderDetailedPage;
		orderProductTablePage.getParameters().put('Id', productList[0].Id);
		PageReference productTablePage = Page.ListOfProducts;

		Test.startTest();
		Pagereference productPage = productTableController.goToProductListPage();
		Pagereference orderProductPage = productTableController.goToOrderDetailedPage();
		Test.stopTest();

		System.assertEquals(orderProductTablePage.getUrl(), orderProductPage.getUrl());
		System.assertEquals(productTablePage.getUrl(), productPage.getUrl());
	}
}
