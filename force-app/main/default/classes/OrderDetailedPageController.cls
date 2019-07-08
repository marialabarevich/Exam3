public with sharing class OrderDetailedPageController {
	private Id receivedProductId;
	public Contact contact { get; set; }
	public Product_Table__c selectedProduct { get; set; }
	private Decimal totalAmount = 0;
	private Integer unitsAvailable = 0;
	public String errorMessage { get; set; }
	public String inputWarningMessage { get; set; }
	public String confirmMessage { get; set; }

	public Integer unitCount { 
		get {
			return unitCount;
		} set {
			if (value <= 0) { 
				unitCount = 0;
			} else {
				unitCount = value;
			}
		}
	}

	public Decimal getUnitsAvailable() {
		if (unitCount > 0) {
			unitsAvailable = (Integer)selectedProduct.Units_Available__c - unitCount;
		} else {
			unitsAvailable = (Integer)selectedProduct.Units_Available__c;
		}
		return unitsAvailable;
	}

	public Decimal getTotalAmount() {
		if (unitCount > 0) {
			totalAmount = unitCount * (Decimal)selectedProduct.Unit_Price__c;
		} else {
			totalAmount = 0;
		}
		return totalAmount;
	}

	public OrderDetailedPageController(ApexPages.StandardController controller) {
		Id receivedProductId = (Id)controller.getId();
		selectedProduct = [
			SELECT Id, Name, Unit_Price__c, Units_Available__c
			FROM Product_Table__c
			WHERE Id =:receivedProductId
			LIMIT 1
		];
		contact = new Contact();
	}

	public void saveOrder() {
		Savepoint cancelContactUpserting = Database.setSavepoint();
		List<Contact> contactToOrderProduct = new List<Contact>();
		List<Order_Table__c> orderTableToProducts = new List<Order_Table__c>();
		if (String.isNotBlank(contact.Email)) {
			List<Contact> existingContacts = [
				SELECT FirstName, LastName, Email
				FROM Contact
				WHERE Email =:contact.Email
			];
			if (existingContacts.size() != 0) {
				contact.Id = existingContacts[0].Id;
				existingContacts[0].FirstName = contact.FirstName;
				existingContacts[0].LastName = contact.LastName;
				contactToOrderProduct.add(existingContacts[0]);
			} else {
				contactToOrderProduct.add(contact);
			}
			try {
				upsert contactToOrderProduct;
				Savepoint cancelOrder = Database.setSavepoint();
				getUnitsAvailable();
				if ((unitCount > 0) && (unitsAvailable >= 0) && (totalAmount > 0)) {
					Order_Table__c newOrder = new Order_Table__c(
						Product_Table__c = selectedProduct.Id,
						Units__c = unitCount,
						Order_Amount__c = totalAmount,
						Contact__c = contact.Id
					);
					orderTableToProducts.add(newOrder);
					insert orderTableToProducts;
				} else {
					Database.rollback(cancelOrder);
					clearPageMessages();
					inputWarningMessage = System.Label.ErrorUnitsAvailable;
				}
				if (orderTableToProducts.size() != 0) {
					selectedProduct.Units_Available__c = unitsAvailable;
					update selectedProduct;
					clearPageMessages();
					confirmMessage = System.Label.SuccessfulOrder;
				}
			} catch (DmlException e) {
				Database.rollback(cancelContactUpserting);
				clearPageMessages();
				errorMessage = System.Label.ErrorLastName;
				}
		} else {
			clearPageMessages();
			inputWarningMessage = System.Label.ErrorEmail;
		}
	}
	
	private void clearPageMessages() {
		errorMessage = '';
		inputWarningMessage = '';
		confirmMessage = '';
	}

	public PageReference goToProductListPage() {
		PageReference productPage = Page.ListOfProducts;
		productPage.setRedirect(true);
		return productPage;
	}
}