require 'spec_helper'

describe Bidu::House::Report::Database do
  describe '#error?' do
    context 'when connection has not been stablished' do
      before do
        allow(ActiveRecord::Base).to receive(:connection).and_raise(StandardError)
      end
      it { expect(subject.error?).to be_truthy }
    end

    context 'when connection has been stablished' do
      before do
        allow(ActiveRecord::Base).to receive(:connection) { connection }
      end

      context 'and it is a mysql2 connection' do
        let(:connection) { ActiveRecord::ConnectionAdapters::Mysql2Adapter.new }
        before do
          allow(connection).to receive(:execute).with('show tables') { true }
        end

        it { expect(subject.error?).to be_falsey }

        context 'but it is failing' do
          before do
            allow(connection).to receive(:execute).and_raise(Mysql2::Error.new(:error))
          end

          it { expect(subject.error?).to be_truthy }
        end
      end
    end
  end
end
