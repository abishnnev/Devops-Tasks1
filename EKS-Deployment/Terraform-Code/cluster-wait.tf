############################################################
# WAIT FOR EKS CLUSTER TO BE READY
############################################################
resource "time_sleep" "wait_for_eks" {
  depends_on = [module.eks]

  create_duration = "30s"
}