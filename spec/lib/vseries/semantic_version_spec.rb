RSpec.describe Vseries::SemanticVersion do
  shared_examples 'comparing two versions' do |version_1, operator, version_2, returns:|
    it "#{version_1} #{operator} #{version_2} returns #{returns}" do
      semantic_1 = described_class.new(version_1)
      semantic_2 = described_class.new(version_2)

      expect(semantic_1.public_send(operator.to_sym, semantic_2)).to eq(returns)
    end
  end

  shared_examples 'comparing versions' do |version_params|
    version_params.each do |version_1, operator, version_2, returns|
      include_examples 'comparing two versions', version_1, operator, version_2, **returns
    end
  end


  describe '#<' do
    include_examples 'comparing versions', [
      ['1.0.0', '<', '1.1.0', returns: true],
      ['1.0.0', '<', '1.0.1', returns: true],
      ['1.0.0', '<', '2.0.0', returns: true],
      ['1.0.0', '<', '2.0.0-rc.1', returns: true],
      ['1.0.0', '<', '1.0.0-rc.1', returns: false],
      ['1.0.0-rc.2', '<', '1.0.0-rc.1', returns: false],
      ['1.0.0-rc.2', '<', '1.0.0-rc.7', returns: true],
      ['1.0.0-rc.10', '<', '1.0.0-rc.9', returns: false],
      ['1.0.0', '<', '0.1.0', returns: false],
      ['1.0.0', '<', '0.0.1', returns: false],
      ['0.1.0', '<', '0.1.0', returns: false],
    ]
  end

  describe '#>' do
    include_examples 'comparing versions', [
      ['1.0.0', '>', '1.1.0', returns: false],
      ['1.0.0', '>', '1.0.1', returns: false],
      ['1.0.0', '>', '2.0.0', returns: false],
      ['1.0.0', '>', '2.0.0-rc.1', returns: false],
      ['1.0.0', '>', '1.0.0-rc.1', returns: true],
      ['1.0.0-rc.2', '>', '1.0.0-rc.1', returns: true],
      ['1.0.0-rc.2', '>', '1.0.0-rc.7', returns: false],
      ['1.0.0-rc.10', '>', '1.0.0-rc.9', returns: true],
      ['1.0.0', '>', '0.1.0', returns: true],
      ['1.0.0', '>', '0.0.1', returns: true],
      ['0.1.0', '>', '0.1.0', returns: false],
    ]
  end

  describe '#==' do
    include_examples 'comparing versions', [
      ['1.0.0', '==', '1.1.0', returns: false],
      ['1.0.0', '==', '1.0.1', returns: false],
      ['1.0.0', '==', '2.0.0', returns: false],
      ['1.0.0', '==', '2.0.0-rc.1', returns: false],
      ['1.0.0', '==', '1.0.0-rc.1', returns: false],
      ['1.0.0-rc.2', '==', '1.0.0-rc.1', returns: false],
      ['1.0.0-rc.2', '==', '1.0.0-rc.7', returns: false],
      ['1.0.0', '==', '0.1.0', returns: false],
      ['1.0.0', '==', '0.0.1', returns: false],
      ['0.1.0', '==', '0.1.0', returns: true],
      ['0.1.0.rc.10', '==', '0.1.0.rc.10', returns: true],
    ]
  end

  describe '#up' do
    subject { instance.up(number_identifier) }

    shared_examples 'up new version' do |specs_args|
      specs_args.each do |spec_args|
        version_1, options = spec_args
        version_2 = options[:returns]
        up_option = options[:up]

        it "ups from #{version_1} to #{version_2}" do
          actual_new_version = described_class.new(version_1).up(up_option)
          expected_new_version = described_class.new(version_2)

          expect(expected_new_version).to eq(actual_new_version)
        end
      end
    end

    context 'with patch' do
      include_examples 'up new version', [
        ['1.1.1', up: :patch, returns: '1.1.2'],
        ['9.3.19', up: :patch, returns: '9.3.20'],
        ['3.0.1-rc.1', up: :patch, returns: '3.0.2-rc.1'],
        ['3.0.99-rc.10', up: :patch, returns: '3.0.100-rc.1'],
      ]

      xcontext 'with pre_release_initial_number'
    end

    context 'with minor' do
      include_examples 'up new version', [
        ['1.1.1', up: :minor, returns: '1.2.0'],
        ['12.3.19', up: :minor, returns: '12.4.0'],
        ['3.0.1-rc.1', up: :minor, returns: '3.1.0-rc.1'],
        ['3.0.99-rc.10', up: :minor, returns: '3.1.0-rc.1'],
      ]

      xcontext 'with pre_release_initial_number'
    end

    context 'with major' do
      include_examples 'up new version', [
        ['1.1.1', up: :major, returns: '2.0.0'],
        ['12.3.19', up: :major, returns: '13.0.0'],
        ['3.0.1-rc.1', up: :major, returns: '4.0.0-rc.1'],
        ['3.0.99-rc.10', up: :major, returns: '4.0.0-rc.1'],
      ]

      xcontext 'with pre_release_initial_number'
    end

    context 'with pre_release' do
      include_examples 'up new version', [
        ['1.1.1-rc.1', up: :pre_release, returns: '1.1.1-rc.2'],
        ['12.3.19-alpha.9', up: :pre_release, returns: '12.3.19-alpha.10'],
        ['3.0.1-rc.8', up: :pre_release, returns: '3.0.1-rc.9'],
      ]

      context 'without a version with pre_relese' do
        it 'raises a error' do
          expect {
            described_class.new('3.0.99').up(:pre_release)
          }.to raise_error(described_class::PreRelease::BlankPreReleaseError)
        end
      end
    end
  end
end
