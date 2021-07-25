RSpec.describe VendingMachine do
  let(:product_id) { '1' }

  describe '#put_coin' do
    it 'tracks current transaction amount' do
      subject.put_coin(5.0)
      expect(subject.total).to eq(5.0)
      expect(subject.coins).to eq([5.0])

      subject.put_coin(2.0)
      expect(subject.total).to eq(7.0)
      expect(subject.coins).to eq([5.0, 2.0])
    end
  end

  describe '#select_product' do
    it 'selects product' do
      subject.select_product(product_id)
      expect(subject.product['name']).to eq('Coca Cola')
    end

    describe 'when wrong id is passed' do
      it 'raises an error' do
        expect { subject.select_product('wrong_id') }.to raise_error(UnknownProductError)
      end
    end

    describe 'when product is out of stock' do
      it 'raises an error' do
        expect { subject.select_product('5') }.to raise_error(OutOfStockError)
      end
    end
  end

  describe '#buy_product' do
    before { subject.select_product(product_id) }

    describe 'when enough money and product is in the stock' do
      it 'decreases product amount' do
        subject.put_coin(2.0)
        expect { subject.buy_product }.to change { subject.products[product_id]['quantity'] }.from(2).to(1)
      end

      it 'collects coins' do
        subject.put_coin(1.0)
        subject.put_coin(0.5)
        subject.put_coin(0.25)
        subject.put_coin(0.25)
        expect { subject.buy_product }.to change { subject.collected_coins['1.0'] }.from(5).to(6)
          .and change { subject.collected_coins['0.5'] }.from(5).to(6)
          .and change { subject.collected_coins['0.25'] }.from(5).to(7)
      end

      it 'gives a change' do
        5.times { subject.put_coin(3.0) }
        3.times { subject.put_coin(0.5) }
        subject.buy_product
        expect(subject.change).to eq([5.0, 5.0, 3.0, 1.0, 0.5])
      end

      describe 'when does not have enough change' do
        let(:product_id) { '3' }

        it 'raises an error' do
          subject.put_coin(5.0)
          expect { subject.buy_product }.to raise_error(NotEnoughChangeError)
        end
      end
    end
  end
end
