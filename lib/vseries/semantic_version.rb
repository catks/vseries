module Vseries
  class SemanticVersion
    include Comparable

    REGEXP = /(\d+)\.(\d+)\.(\d+)(-?.*)/
    DEFAULT_PRE_RELEASE_INITIAL_NUMBER = 1

    class PreRelease
      include Comparable

      REGEXP = /-?(.+)\.(\d+)/
      BlankPreReleaseError = Class.new(StandardError)

      attr_accessor :name, :number

      def self.with(name:, number: DEFAULT_PRE_RELEASE_INITIAL_NUMBER)
        instance = allocate
        instance.name = name
        instance.number = number
        instance
      end

      def initialize(pre_release, initial_number: DEFAULT_PRE_RELEASE_INITIAL_NUMBER)
        name, number = pre_release.match(REGEXP)&.captures

        @initial_number = initial_number
        return if name.nil? && number.nil?

        @name = name
        @number = number ? number.to_i : initial_number
      end

      def up
        raise BlankPreReleaseError if blank?

        new_pre_release = self.dup
        new_pre_release.number = number ? number + 1 : @initial_number
        new_pre_release
      end

      def <=>(other)
        return  0 if blank? && other.blank?
        return -1 if present? && other.blank?
        return  1 if blank? && other.present?
        return  1 if @name > other.name

        @number <=> other.number
      end

      def blank?
        name.nil? && number.nil?
      end

      def present?
        !blank?
      end

      def to_s
        return '' if blank?

        "-#{@name}.#{@number}"
      end
    end

    attr_accessor :major, :minor, :patch, :pre_release

    def initialize(version, pre_release_initial_number: DEFAULT_PRE_RELEASE_INITIAL_NUMBER)
      major, minor, patch, pre_release = version.match(REGEXP).captures

      @major = major.to_i
      @minor = minor.to_i
      @patch = patch.to_i
      @pre_release = PreRelease.new(pre_release)

      @pre_release_initial_number = pre_release_initial_number

      freeze
    end

    def up(version_type)
      new_version = self.dup

      case version_type
      when :major
        new_version.major += 1
        new_version.minor = 0
        new_version.patch = 0
        new_version.pre_release.number = @pre_release_initial_number if pre_release?
      when :minor
        new_version.minor += 1
        new_version.patch = 0
        new_version.pre_release.number = @pre_release_initial_number if pre_release?
      when :patch
        new_version.patch += 1
        new_version.pre_release.number = @pre_release_initial_number if pre_release?
      when :pre_release
        new_version.pre_release = new_version.pre_release.up
      end

      new_version
    end

    def with_pre_release(name)
      new_version = self.dup

      return new_version if new_version.pre_release? && new_version.pre_release.name == name

      new_version.pre_release = PreRelease.with(name: name)

      new_version
    end

    def pre_release?
      pre_release.present?
    end

    def <=>(other)
      return 1 if major > other.major
      return 1 if major == other.major && minor > other.minor
      return 1 if major == other.major && minor == other.minor && patch > other.patch
      return 1 if major == other.major && minor == other.minor && patch == other.patch && pre_release > other.pre_release
      return 0 if major == other.major && minor == other.minor && patch == other.patch && pre_release == other.pre_release

      -1
    end

    def to_s
      version = "#{@major}.#{@minor}.#{@patch}"
      version << @pre_release.to_s if @pre_release
      version
    end
  end
end
