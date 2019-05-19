# frozen_string_literal: true

require 'spec_helper'

describe DocumentReportController, type: :controller do
  describe 'error reports' do
    let(:successes_a)     { 0 }
    let(:successes_b)     { 0 }
    let(:successes_c)     { 0 }
    let(:errors_a)        { 0 }
    let(:errors_b)        { 0 }
    let(:errors_c)        { 0 }
    let(:old_errors_a)    { 0 }
    let(:old_errors_b)    { 0 }
    let(:old_errors_c)    { 0 }
    let(:parameters)      { {} }

    let(:error_documents) do
      Document.with_error.where(updated_at: (2.hours.ago..1.minute.from_now))
    end

    let(:parsed_response) do
      JSON.parse(response.body)
    end

    let(:expected_status)            { 'ok' }
    let(:expected_error_ids_type_a)  { [] }
    let(:expected_percentage_type_a) { 0 }
    let(:expected_status_type_a)     { 'ok' }
    let(:expected_error_ids_type_b)  { [] }
    let(:expected_percentage_type_b) { 0 }
    let(:expected_status_type_b)     { 'ok' }
    let(:expected_error_ids_type_c)  { [] }
    let(:expected_percentage_type_c) { 0 }
    let(:expected_status_type_c)     { 'ok' }

    let(:expected_response) do
      {
        status: expected_status,
        error_a: {
          ids:        expected_error_ids_type_a,
          percentage: expected_percentage_type_a,
          status:     expected_status_type_a
        },
        error_b: {
          ids:        expected_error_ids_type_b,
          percentage: expected_percentage_type_b,
          status:     expected_status_type_b
        },
        error_c: {
          ids:        expected_error_ids_type_c,
          percentage: expected_percentage_type_c,
          status:     expected_status_type_c
        }
      }.deep_stringify_keys
    end


    before do
      Document.delete_all

      successes_a.times { Document.with_success.type_a.create }
      successes_b.times { Document.with_success.type_b.create }
      successes_c.times { Document.with_success.type_c.create }
      errors_a.times    { Document.with_error.type_a.create }
      errors_b.times    { Document.with_error.type_b.create }
      errors_c.times    { Document.with_error.type_c.create }

      old_errors_a.times do
        Document.with_error.type_a.create(updated_at: 1.day.ago)
      end
      old_errors_b.times do
        Document.with_error.type_b.create(updated_at: 1.day.ago)
      end
      old_errors_c.times do
        Document.with_error.type_c.create(updated_at: 1.day.ago)
      end

      get :error_status, params: parameters
    end

    context 'when there are no documents' do
      it 'returns 200' do
        expect(response).to be_successful
      end

      it 'returns status json' do
        expect(parsed_response).to eq(expected_response)
      end
    end

    context 'when there are only old documents' do
      let(:old_errors_1) { 2 }
      let(:old_errors_b) { 2 }

      it 'ignore old entries' do
        expect(response).to be_successful
      end

      it 'returns status json' do
        expect(parsed_response).to eq(expected_response)
      end
    end

    context 'when there are errors above the threshold' do
      let(:errors_a)    { 3 }
      let(:successes_a) { 1 }

      let(:expected_status)            { 'error' }
      let(:expected_percentage_type_a) { 0.75 }
      let(:expected_status_type_a)     { 'error' }
      let(:expected_error_ids_type_a) do
        error_documents.pluck(:id)
      end

      it 'returns 500' do
        expect(response.status).to eq(500)
      end

      it 'returns status json' do
        expect(parsed_response).to eq(expected_response)
      end
    end

    context 'when there are errors below the threshold' do
      let(:successes_a) { 49 }
      let(:errors_b)    { 1 }

      let(:expected_error_ids_type_b)  { error_documents.pluck(:id) }
      let(:expected_percentage_type_b) { 0.02 }

      it 'returns success' do
        expect(response).to be_successful
      end

      it 'returns status json' do
        expect(parsed_response).to eq(expected_response)
      end
    end

    context 'when parameters are given' do
      let(:successes_a) { 1 }
      let(:successes_b) { 1 }

      context 'when setting a new scope' do
        let(:parameters) { { scope: :all } }

        it 'ignores scopes overwrite' do
          expect(response).to be_successful
        end

        it 'returns status json' do
          expect(parsed_response).to eq(expected_response)
        end
      end

      context 'when setting a new threshold' do
        let(:errors_b)                   { 2 }
        let(:parameters)                 { { threshold: 0.5 } }
        let(:expected_percentage_type_b) { 0.5 }
        let(:expected_error_ids_type_b)  { error_documents.pluck(:id) }

        it 'uses the given threashold' do
          expect(response).to be_successful
        end

        it 'returns status json' do
          expect(parsed_response).to eq(expected_response)
        end
      end

      context 'when setting a new period' do
        let(:parameters)                 { { period: '2day' } }
        let(:old_errors_b)               { 2 }
        let(:expected_percentage_type_b) { 0.5 }
        let(:expected_error_ids_type_b)  { error_documents.pluck(:id) }
        let(:expected_status)            { 'error' }
        let(:expected_status_type_b)     { 'error' }
        let(:error_documents)            { Document.with_error }

        it 'uses the given period' do
          expect(response.status).to eq(500)
        end

        it 'returns status json' do
          expect(parsed_response).to eq(expected_response)
        end
      end
    end

    context 'when scope is defined as string' do
      let(:successes_a)     { 10 }
      let(:successes_b)     { 10 }
      let(:successes_c)     { 5 }
      let(:errors_c)        { 5 }
      let(:old_errors_c)    { 10 }

      let(:expected_percentage_type_c) { 0.5 }
      let(:expected_error_ids_type_c)  { error_documents.pluck(:id) }

      it 'Returns the status' do
        expect(response).to be_successful
      end

      it 'returns status json' do
        expect(parsed_response).to eq(expected_response)
      end
    end
  end
end
