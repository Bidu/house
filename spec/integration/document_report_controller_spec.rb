# frozen_string_literal: true

require 'spec_helper'

describe DocumentReportController, type: :controller do
  context 'when all reports are successful' do
    let(:successes_a)     { 0 }
    let(:successes_b)     { 0 }
    let(:errors_a)        { 0 }
    let(:errors_b)        { 0 }
    let(:error_documents) { Document.with_error }

    let(:parsed_response) do
      JSON.parse(response.body)
    end

    before do
      Document.delete_all

      successes_a.times { Document.with_success.type_a.create }
      successes_b.times { Document.with_success.type_b.create }
      errors_a.times    { Document.with_error.type_a.create }
      errors_b.times    { Document.with_error.type_b.create }

      get :status
    end

    context 'when there are no documents' do
      let(:expected_response) do
        {
          status: 'ok',
          error_a: {
            ids:        [],
            percentage: 0,
            status:     'ok'
          },
          error_b: {
            ids:        [],
            percentage: 0,
            status:     'ok'
          }
        }.deep_stringify_keys
      end

      it 'returns 200' do
        expect(response).to be_successful
      end

      it 'returns status json' do
        expect(parsed_response).to eq(expected_response)
      end
    end

    context 'when there are errors above the threshold' do
      let(:errors_a)    { 3 }
      let(:successes_a) { 1 }

      let(:expected_response) do
        {
          status: 'error',
          error_a: {
            ids:        error_documents.pluck(:id),
            percentage: 0.75,
            status:     'error'
          },
          error_b: {
            ids:        [],
            percentage: 0,
            status:     'ok'
          }
        }.deep_stringify_keys
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

      let(:expected_response) do
        {
          status: 'ok',
          error_a: {
            ids:        [],
            percentage: 0,
            status:     'ok'
          },
          error_b: {
            ids:        error_documents.pluck(:id),
            percentage: 0.02,
            status:     'ok'
          }
        }.deep_stringify_keys
      end

      it 'returns success' do
        expect(response).to be_successful
      end

      it 'returns status json' do
        expect(parsed_response).to eq(expected_response)
      end
    end
  end
end
