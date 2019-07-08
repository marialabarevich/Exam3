@isTest
public with sharing class OrderDetailedPageControllerTest {
	@TestSetup
	static void makeData() {
		List<SObject> testData = new List<SObject>();
		Product_Table__c product = new Product_Table__c(
			Name = 'M. Shelly "Frankenstein"',
			Product_Description__c = 'On the surface, it is a novel of tense and steadily mounting horror.',
			Image_Url__c = 'https://images-na.ssl-images-amazon.com/images/I/91%2BkeCUpW3L.jpg',
			Unit_Price__c = 35,
			Units_Available__c = 250
		);
		testData.add(product);
		Contact customerContact = new Contact(
			FirstName = 'Test',
			LastName = 'Contact',
			Email = 'testContact@test.test'
		);
		testData.add(customerContact);
		insert testData;
	}
	@isTest 
	public static void saveOrderWithNewContactTest() {
		Product_Table__c product = [
			SELECT Id, Name, Unit_Price__c, Units_Available__c
			FROM Product_Table__c
			WHERE Name = 'M. Shelly "Frankenstein"'
			LIMIT 1
		];
		ApexPages.StandardController stdController = new ApexPages.StandardController(product);
		OrderDetailedPageController orderDetailedPageController = new OrderDetailedPageController(stdController);
		PageReference productTablePage = Page.ListOfProducts;

		orderDetailedPageController.contact = new Contact(
			FirstName = 'Test',
			LastName = 'Contact',
			Email = 'test@test.test'
		);
		List<Order_Table__c> orderList = [
			SELECT Id
			FROM Order_Table__c
			WHERE Product_Table__c = :product.Id
		];
		System.assertEquals(0, orderList.size());
		List<Contact> contactList = [
			SELECT Id
			FROM Contact
			WHERE Email = 'test@test.test'
		];
		System.assertEquals(0, contactList.size());

		Test.startTest();
		orderDetailedPageController.unitCount = 20;
		Decimal actualTotalAmount = orderDetailedPageController.getTotalAmount();
		Decimal actualAvailableUnits = orderDetailedPageController.getUnitsAvailable();
		orderDetailedPageController.saveOrder();
		Pagereference tablePage = orderDetailedPageController.goToProductListPage();
		Test.stopTest();

		List<Contact> contactListAfterBuying = [
			SELECT Id
			FROM Contact
			WHERE Email = 'test@test.test'
		];
		List<Order_Table__c> orderListAfterBuying = [
			SELECT Id
			FROM Order_Table__c
			WHERE Product_Table__c = :product.Id
		];

		System.assertEquals(1, orderListAfterBuying.size());
		System.assertEquals(1, contactListAfterBuying.size());
		System.assertEquals(productTablePage.getUrl(), tablePage.getUrl());
		System.assertEquals(product.Unit_Price__c * orderDetailedPageController.unitCount, actualTotalAmount);
		System.assertEquals(product.Units_Available__c - orderDetailedPageController.unitCount, actualAvailableUnits);
		System.assertEquals(System.Label.SuccessfulOrder, orderDetailedPageController.confirmMessage);
		System.assertEquals(true, String.isBlank(orderDetailedPageController.errorMessage));
		System.assertEquals(true, String.isBlank(orderDetailedPageController.inputWarningMessage));
	}

	@isTest
	public static void saveOrderWithContactEmailErrorTest() {
		Product_Table__c product = [
			SELECT Id, Name, Unit_Price__c, Units_Available__c
			FROM Product_Table__c
			WHERE Name = 'M. Shelly "Frankenstein"'
			LIMIT 1
		];
		ApexPages.StandardController stdController = new ApexPages.StandardController(product);
		OrderDetailedPageController orderDetailedPageController = new OrderDetailedPageController(stdController);
		PageReference productTablePage = Page.ListOfProducts;
		String expectedWarningMessage = System.Label.ErrorEmail;
		orderDetailedPageController.contact = new Contact(
			FirstName = 'Test',
			LastName = 'Contact'
		);

		Test.startTest();
		orderDetailedPageController.saveOrder();
		Pagereference tablePage = orderDetailedPageController.goToProductListPage();
		Test.stopTest();

		List<Order_Table__c> orderListAfterBuying = [
			SELECT Id
			FROM Order_Table__c
			WHERE Product_Table__c = :product.Id
		];
		System.assertEquals(0, orderListAfterBuying.size());
		System.assertEquals(productTablePage.getUrl(), tablePage.getUrl());
		System.assertEquals(true, String.isBlank(orderDetailedPageController.confirmMessage));
		System.assertEquals(true, String.isBlank(orderDetailedPageController.errorMessage));
		System.assertEquals(expectedWarningMessage, orderDetailedPageController.inputWarningMessage);
	}

	@isTest
	public static void saveOrderWithLastNameErrorTest() {
		Product_Table__c product = [
			SELECT Id, Name, Unit_Price__c, Units_Available__c
			FROM Product_Table__c
			WHERE Name = 'M. Shelly "Frankenstein"'
			LIMIT 1
		];

		ApexPages.StandardController stdController = new ApexPages.StandardController(product);
		OrderDetailedPageController orderDetailedPageController = new OrderDetailedPageController(stdController);
		PageReference productTablePage = Page.ListOfProducts;
		String expectedErrorMessage = System.Label.ErrorLastName;
		orderDetailedPageController.contact = new Contact(
			FirstName = 'Test',
			Email = 'testContact@test.test'
		);
		Test.startTest();
		orderDetailedPageController.saveOrder();
		Pagereference tablePage = orderDetailedPageController.goToProductListPage();
		Test.stopTest();

		List<Order_Table__c> orderListAfterBuying = [
			SELECT Id
			FROM Order_Table__c
			WHERE Product_Table__c = :product.Id
		];
		System.assertEquals(0, orderListAfterBuying.size());
		System.assertEquals(productTablePage.getUrl(), tablePage.getUrl());
		System.assertEquals(true, String.isBlank(orderDetailedPageController.confirmMessage));
		System.assertEquals(true, String.isBlank(orderDetailedPageController.inputWarningMessage));
		System.assertEquals(expectedErrorMessage, orderDetailedPageController.errorMessage);
	}

	@isTest
	public static void saveOrderWithUnitsAvailableErrorTest() {
		Product_Table__c product = [
			SELECT Id, Name, Unit_Price__c, Units_Available__c
			FROM Product_Table__c
			WHERE Name = 'M. Shelly "Frankenstein"'
			LIMIT 1
		];
		ApexPages.StandardController stdController = new ApexPages.StandardController(product);
		OrderDetailedPageController orderDetailedPageController = new OrderDetailedPageController(stdController);
		PageReference productTablePage = Page.ListOfProducts;
		String newLastName = 'New Last Name';
		String expectedWarningMessage = System.Label.ErrorUnitsAvailable;
		orderDetailedPageController.contact = new Contact(
			Email = 'testContact@test.test',
			FirstName = 'Test',
			LastName = newLastName
		);

		Test.startTest();
		orderDetailedPageController.unitCount = 0;
		Decimal actualTotalAmount = orderDetailedPageController.getTotalAmount();
		Decimal actualAvailableUnits = orderDetailedPageController.getUnitsAvailable();
		orderDetailedPageController.saveOrder();
		Test.stopTest();

		Contact contactAfterBuying = [
			SELECT Id, LastName
			FROM Contact
			WHERE Email = 'testContact@test.test'
			LIMIT 1
		];
		List<Order_Table__c> orderListAfterBuying = [
			SELECT Id
			FROM Order_Table__c
			WHERE Product_Table__c = :product.Id
		];

		System.assertEquals(newLastName, contactAfterBuying.LastName);
		System.assertEquals(0, orderListAfterBuying.size());
		System.assertEquals(0, actualTotalAmount);
		System.assertEquals(product.Units_Available__c, actualAvailableUnits);
		System.assertEquals(true, String.isBlank(orderDetailedPageController.confirmMessage));
		System.assertEquals(true, String.isBlank(orderDetailedPageController.errorMessage));
		System.assertEquals(expectedWarningMessage, orderDetailedPageController.inputWarningMessage);
	}
}