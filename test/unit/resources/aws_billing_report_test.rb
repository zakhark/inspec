require 'helper'

class EmptyAwsBillingReportTest < Minitest::Test
  def setup
    AwsBillingReport::BackendFactory.select(MockAwsBillingReport::Empty)
  end

  def test_empty_query
    assert_raises(ArgumentError) { AwsBillingReport.new }
  end
end

class BasicAwsBillingReportTest < Minitest::Test
  def setup
    AwsBillingReport::BackendFactory.select(MockAwsBillingReport::Basic)
  end

  def test_search_hit_via_scalar
    assert AwsBillingReport.new('inspec1').exists?
  end

  def test_search_miss_via_scalar
    refute AwsBillingReport.new('non-existant').exists?
  end

  def test_search_hit_via_hash_works
    assert AwsBillingReport.new(report_definition: 'inspec1').exists?
  end

  def test_search_miss_is_not_an_exception
    refute AwsBillingReport.new(report_definition: 'non-existant').exists?
  end

  def test_search_hit_properties
    r = AwsBillingReport.new('inspec1')
    assert_equal('inspec1', r.report_name)
    assert_equal('HOURLY', r.time_unit)
    assert_equal('textORcsv', r.format)
    assert_equal('ZIP', r.compression)
    assert_equal('inspec1-s3-bucket', r.s3_bucket)
    assert_equal('inspec1', r.s3_prefix)
    assert_equal('us-east-1', r.s3_region)
    assert_equal(['REDSHIFT'], r.additional_artifacts)
    assert_equal(['RESOURCES'], r.additional_schema_elements)
  end
end

module MockAwsBillingReport
  class Empty < AwsBackendBase
    def describe_report_definitions
      OpenStruct.new(report_definitions: [])
    end
  end

  class Basic < AwsBackendBase
    def describe_report_definitions
        OpenStruct.new(report_definitions: [
          Aws::CostandUsageReportService::Types::ReportDefinition.new(
            report_name: 'inspec1',
            time_unit: 'HOURLY',
            format: 'textORcsv',
            compression: 'ZIP',
            s3_bucket: 'inspec1-s3-bucket',
            s3_prefix: 'inspec1',
            s3_region: 'us-east-1',
            additional_artifacts: ["REDSHIFT"],
            additional_schema_elements: ['RESOURCES']
          ),
          Aws::CostandUsageReportService::Types::ReportDefinition.new(
            report_name: 'inspec2',
            time_unit: 'DAILY',
            format: 'textORcsv',
            compression: 'GZIP',
            s3_bucket: 'inspec2-s3-bucket',
            s3_prefix: 'inspec2',
            s3_region: 'us-west-1',
            additional_artifacts: ['QUICKSIGHT'],
            additional_schema_elements: ['RESOURCES']
          ),
        ])
    end
  end
end
