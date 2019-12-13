ARGOCD_VERSION     = 1.3.6
KIND_VERSION       = 0.6.1
KUBERNETES_VERSION = 1.16.3
KUSTOMIZE_VERSION  = 3.1.0

BIN_DIR   = /usr/local/bin
ARGOCD    = $(BIN_DIR)/argocd
KIND      = $(BIN_DIR)/kind
KUBECTL   = $(BIN_DIR)/kubectl
KUSTOMIZE = $(BIN_DIR)/kustomize

SUDO = sudo

CLUSTER_NAME = kind
OUTPUT_DIR   = output

.PHONY: default
default: start

.PHONY: setup
setup: $(ARGOCD) $(KIND) $(KUBECTL) $(KUSTOMIZE)

$(ARGOCD):
	$(SUDO) curl -sSL -o $@ https://github.com/argoproj/argo-cd/releases/download/v$(ARGOCD_VERSION)/argocd-linux-amd64
	$(SUDO) chmod +x $@

$(KIND):
	$(SUDO) curl -sSL -o $@ https://github.com/kubernetes-sigs/kind/releases/download/v$(KIND_VERSION)/kind-linux-amd64
	$(SUDO) chmod +x $@

$(KUBECTL):
	$(SUDO) curl -sSL -o $@ https://storage.googleapis.com/kubernetes-release/release/v$(KUBERNETES_VERSION)/bin/linux/amd64/kubectl
	$(SUDO) chmod +x $@

$(KUSTOMIZE):
	$(SUDO) curl -sSL -o $@ https://github.com/kubernetes-sigs/kustomize/releases/download/v$(KUSTOMIZE_VERSION)/kustomize_$(KUSTOMIZE_VERSION)_linux_amd64
	$(SUDO) chmod +x $@

.PHONY: start
start:
	-@mkdir $(OUTPUT_DIR)
	sed s/@KUBERNETES_VERSION@/$(KUBERNETES_VERSION)/ cluster.yaml > $(OUTPUT_DIR)/cluster.yaml
	$(KIND) create cluster --config $(OUTPUT_DIR)/cluster.yaml --image kindest/node:v$(KUBERNETES_VERSION) --name=$(CLUSTER_NAME)
	$(KIND) get kubeconfig --name $(CLUSTER_NAME) > $(OUTPUT_DIR)/kind_config
	@echo "*******************************************"
	@echo
	@echo "export KUBECONFIG=$(OUTPUT_DIR)/kind_config"
	@echo
	@echo "*******************************************"

.PHONY: stop
stop:
	-$(KIND) delete cluster --name=$(CLUSTER_NAME)

.PHONY: run-argocd
run-argocd:
	@export KUBECONFIG=$(OUTPUT_DIR)/kind_config kubectl create namespace argocd
	$(KUBECTL) create namespace argocd
	$(KUBECTL) apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v$(ARGOCD_VERSION)/manifests/install.yaml

.PHONY: login-argocd
login-argocd:
	@export KUBECONFIG=$(OUTPUT_DIR)/kind_config kubectl create namespace argocd
	$(KUBECTL) get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2 > $(OUTPUT_DIR)/argocd-password
	$(KUBECTL) port-forward svc/argocd-server -n argocd 8080:443 > $(OUTPUT_DIR)/argocd-port-forward.log 2>&1 &
	sleep 10
	$(ARGOCD) login 127.0.0.1:8080 --insecure --username admin --password $$(cat $(OUTPUT_DIR)/argocd-password)

.PHONY: clean
clean: stop
	-rm $(OUTPUT_DIR)/*
	-rmdir $(OUTPUT_DIR)

.PHONY: distclean
distclean: clean
	-$(SUDO) rm $(ARGOCD)
	-$(SUDO) rm $(KIND)
	-$(SUDO) rm $(KUBECTL)
	-$(SUDO) rm $(KUSTOMIZE)

