exports.defineAutoTests = function() {

  describe('Payment Plugin unit tests', function() {
	var payment;
	beforeEach(function() {
	payment = Payment.init("");
	});
	it('do something sync', function() {
       expect(1).toBe(1);
       expect(payment.init).not.toBe(null);
    });

    it('do something async', function(done) {
      setTimeout(function() {
        expect(1).toBe(1);        
        done();
      }, 100);
    });
  });

  describe('more awesome tests', function() {
    it('should write my name', function(){
		expect(true).toBe(true);
	});
  });
};