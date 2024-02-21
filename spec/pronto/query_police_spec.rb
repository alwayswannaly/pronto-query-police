require 'spec_helper'

QUERY_POLICE_MOCK_REPORT = <<-HEREDOC
{
  "/test.txt:2:in `after_create_actions'": {
    "debt": 840.0,
    "query": "SELECT  `user_company_profiles`.* FROM `user_company_profiles` WHERE `user_company_profiles`.`user_id` = 1 LIMIT 1",
    "file": "/app/models/user.rb:2747:in `after_create_actions'",
    "analysis": "Bad Query"
  },
  "/test.txt:4:in `initialize'": {
    "debt": 740.0,
    "query": "SELECT  `users`.* FROM `users` WHERE `users`.`id` = 1 LIMIT 1",
    "file": "/app/services/users/analytics/identifier/generate_service.rb:28:in `initialize'",
    "analysis": "Bad Query"
  }
}
HEREDOC

module Pronto
  describe QueryPolice do
    let(:query_police) { QueryPolice.new(patches) }
    let(:patches) { [] }

    describe '#run' do
      around(:example) do |example|
        create_repository
        Dir.chdir(repository_dir) do
          example.run
        end
        delete_repository
      end

      let(:patches) { Pronto::Git::Repository.new(repository_dir).diff('master') }

      context 'patches are nil' do
        let(:patches) { nil }

        it 'returns an empty array' do
          expect(query_police.run).to eql([])
        end
      end

      context 'no patches' do
        let(:patches) { [] }

        it 'returns an empty array' do
          expect(query_police.run).to eql([])
        end
      end

      context 'with patch data' do
        before(:each) do
          add_to_index(Pronto::QueryPolice::REPORT_NAME, QUERY_POLICE_MOCK_REPORT)
        end

        before(:each) do
          content = <<-HEREDOC
          Line 1 text
          Line 2 text
          Line 3 text
          HEREDOC

          add_to_index('test.txt', content)

          create_commit
        end

        context 'with warnings' do
          before(:each) do
            create_branch('staging', checkout: true)

            updated_content = <<-HEREDOC
            Line 1 text
            Line 2 text ... shit
            Line 3 text
            Line 4 Text
            HEREDOC

            add_to_index('test.txt', updated_content)

            create_commit
          end

          it 'returns correct number of warnings' do
            expect(query_police.run.count).to eql(2)
          end

          it 'has correct messages' do
            expect(query_police.run.map {|r| r.msg }).to eql([
              "Query with debt - 840.0 detected",
              "Query with debt - 740.0 detected"
            ])
          end
        end

        context 'no file matches' do
          before(:each) do
            create_branch('staging', checkout: true)

            add_to_index('random.js', 'alert("Hello World!")');

            create_commit
          end

          it 'returns no warnings' do
            expect(query_police.run.count).to eql(0)
          end
        end
      end
    end
  end
end
