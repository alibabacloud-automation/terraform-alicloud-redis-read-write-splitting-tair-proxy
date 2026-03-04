# Complete Example

Configuration in this directory creates a complete Redis read-write splitting infrastructure with Tair Proxy.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

## Cost

This example provisions multiple resources that will incur costs:
- VPC and VSwitch (no charge)
- ECS instance
- Redis (Tair) instance with read replicas
- Public bandwidth

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
