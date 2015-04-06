require "spec_helper"

module Terraforming::Resource
  describe SecurityGroup do
    let(:client) do
      Aws::EC2::Client.new(stub_responses: true)
    end

    let(:security_groups) do
      [
        {
          owner_id: "012345678901",
          group_name: "hoge",
          group_id: "sg-1234abcd",
          description: "Group for hoge",
          ip_permissions: [
            {
              ip_protocol: "tcp",
              from_port: 22,
              to_port: 22,
              user_id_group_pairs: [],
              ip_ranges: [
                { cidr_ip: "0.0.0.0/0" }
              ]
            }
          ],
          ip_permissions_egress: [
            {
              ip_protocol: "-1",
              user_id_group_pairs: [],
              ip_ranges: [
                { cidr_ip: "0.0.0.0/0" }
              ]
            },
          ],
          tags: []
        },
        {
          owner_id: "098765432109",
          group_name: "fuga",
          group_id: "sg-5678efgh",
          description: "Group for fuga",
          ip_permissions: [
            {
              ip_protocol: "tcp",
              from_port: 1,
              to_port: 65535,
              user_id_group_pairs: [
                {
                  user_id: "user1",
                  group_name: "group1",
                  group_id: "sg-9012ijkl"
                }
              ],
              ip_ranges: []
            },
            {
              ip_protocol: "tcp",
              from_port: 22,
              to_port: 22,
              user_id_group_pairs: [],
              ip_ranges: [
                { cidr_ip: "0.0.0.0/0" }
              ]
            },
          ],
          ip_permissions_egress: [],
          tags: [
            { key: "Name", value: "fuga" }
          ]
        }
      ]
    end

    before do
      client.stub_responses(:describe_security_groups, security_groups: security_groups)
    end

    describe ".tf" do
      it "should generate tf" do
        expect(described_class.tf(client)).to eq <<-EOS
resource "aws_security_group" "hoge" {
    name        = "hoge"
    description = "Group for hoge"
    owner_id    = "012345678901"

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "fuga" {
    name        = "fuga"
    description = "Group for fuga"
    owner_id    = "098765432109"

    ingress {
        from_port       = 1
        to_port         = 65535
        protocol        = "tcp"
        security_groups = ["sg-9012ijkl"]
    }

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }


    tags {
        Name = "fuga"
    }
}

        EOS
      end
    end

    describe ".tfstate" do
      xit "should generate tfstate"
    end
  end
end
