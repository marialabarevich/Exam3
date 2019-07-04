public with sharing class ProductDetailedPageController {
	public Id currentProductId { get; set; }
	public ProductDetailedPageController(ApexPages.StandardController stdController) {}

	public PageReference goToProductListPage() {
		PageReference productPage = Page.ListOfProducts;
		productPage.setRedirect(true);
		return productPage;
	}

	public PageReference goToOrderDetailedPage() {
		PageReference orderPage = Page.OrderDetailedPage;
		orderPage.getParameters().put('Id', currentProductId);
		orderPage.setRedirect(true);
		return orderPage;
	}
}