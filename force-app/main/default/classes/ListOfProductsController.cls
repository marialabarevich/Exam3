public with sharing class ListOfProductsController {
	public Id currentProductId { get; set; }
	public ListOfProductsController(ApexPages.StandardSetController controller) {}

	public PageReference goToProductDetailedPage() {
		PageReference detailedPage = Page.ProductDetailedPage;
		detailedPage.getParameters().put('Id', currentProductId);
		detailedPage.setRedirect(true);
		return detailedPage;
	}

	public PageReference goToOrderDetailedPage() {
		PageReference orderPage = Page.OrderDetailedPage;
		orderPage.getParameters().put('Id', currentProductId);
		//orderPage.setRedirect(true);
		return orderPage;
	}

}