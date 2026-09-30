resource "aws_ebs_snapshot_block_public_access" "ebs_snap_block_sharing" {
  state = "block-all-sharing"
}