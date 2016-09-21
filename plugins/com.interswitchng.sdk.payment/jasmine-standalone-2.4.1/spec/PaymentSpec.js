describe("initialization of Payment Plugin", function(){
  var payment;
  beforeEach(function() {
    payment = new PaymentPlugin();
  });

  it("should be able instantiate Payment Plugin", function(){
    expect(payment).not.toBe(null);
  });
  it("should be able initialize the Plugin class", function(){
      expect(payment.init).not.toBe(null);
      expect(payment.init).toBeDefined();
  });
});

describe("The test class for Payment Plugin", function(){
  var payment;
  beforeEach(function() {
    payment = new PaymentPlugin();
  });

  it("should be able to validate card", function(){
  var validateCardRequest = {
    customerId : 1234567890 // Optional email, mobile no, BVN etc to uniquely identify the customer
  };
   //var validateCard = payment.validatePaymentCard(validateCardRequest);
    expect(payment).not.toBe(null);
  });
  it("should be able to initialize the Plugin class", function(){
      expect(payment.init).not.toBe(null);
  });
});