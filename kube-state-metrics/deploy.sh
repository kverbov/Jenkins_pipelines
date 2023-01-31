#!/usr/bin/env bash
# set -o errexit
set -o xtrace
set -o pipefail
set -o nounset

# Error check function
# Summary: compares input code with 0 and if it's not zero - then it shouts the 2nd arg and exits with input code.
# expects 2 args:
#		- exit code
#		- string to echo
err_check() {
    if (( "${1}" != 0 )); then
        printf "Exit code: ${1}.\n${2}"
        exit "${1}"
    fi
}

if [[ "${STAND}" == @('cert'|'prod') ]]; then
    oc image mirror "${IMAGE_IN_NEXUS}:${TAG}" "${IMAGE_IN_QUAY}:${TAG}" --insecure=true --skip-mount=true --force=true
    err_check "${?}" "Failed to mirror image '${IMAGE_IN_NEXUS}:${TAG}' -> '${IMAGE_IN_QUAY}:${TAG}'."
fi

NAMESPACES="admc-${STAND},audt-${STAND},cash-${STAND},crls-${STAND},dbzm-${STAND},drrr-common,drrr-${STAND},drfs-${STAND},evau-${STAND},evo-${STAND},ips-${STAND},lpet-${STAND},nsdp-${STAND},oapi-gord-${STAND},online-web-${STAND},orid-${STAND},pnb-${STAND},rbcn-${STAND},rrrp-atm-${STAND},rrrp-chat-${STAND},rrrp-corp-${STAND},rrrp-nfo-${STAND},rrrp-payr-${STAND},rrrp-react-${STAND},scrb-${STAND},svng-${STAND},tcom-${STAND}"
if [[ "${STAND}" == 'test' ]]; then
    NAMESPACES+=",drrr-common,retail-devtest"
elif [[ "${STAND}" == 'prod' ]]; then
    NAMESPACES+=",drrr-common,retail-certprod"
elif [[ "${STAND}" == 'dr' ]]; then
    NAMESPACES="admc-prod,dbzm-prod,drrr-prod,drfs-prod,evo-prod,ips-prod,nsdp-prod,orid-prod,scrb-prod,tcom-prod,drrr-common,retail-certprod"
fi

oc login "${OPENSHIFT_API_URL}" -u="${OPENSHIFT_USERNAME}@${DOMAIN}" -p="${OPENSHIFT_PASSWORD}" --insecure-skip-tls-verify=true
err_check "${?}" "Failed to log in."
oc project "${NAMESPACE}"
err_check "${?}" "Failed to switch to project '${NAMESPACE}'."
cd "${SVC_NAME}"
err_check "${?}" "Failed to cd to '${SVC_NAME}'."
sed -i k8s.app.template.yaml \
    -e "s|%SVC_NAME%|${SVC_NAME//_/-}|g" \
    -e "s|%NAMESPACE%|${NAMESPACE}|g" \
    -e "s|%NAMESPACES%|${NAMESPACES}|g" \
    -e "s|%IMAGE%|${IMAGE}|g" \
    -e "s|%TAG%|${TAG}|g" \
    -e "s|%STAND%|${STAND}|g"
err_check "${?}" "One of the sed inline replacements failed."
oc create configmap "${SVC_NAME}" --from-file=configmaps/"${STAND}"/ -o yaml --dry-run | head -n -4 | tail -n +3 | awk '{ print "    " $0 }' >> k8s.app.template.yaml
cat k8s.app.template.yaml
TMPL=$(oc process -f k8s.app.template.yaml)
oc create -f - <<< "${TMPL}" || oc apply -f - <<< "${TMPL}"
err_check "${?}" "Failed either to create new or update existing k8s resources template from k8s.app.template.yaml."
echo "Deploying service '${SVC_NAME}' to namespace '${NAMESPACE}' (of '${STAND}' OpensShift) from image '${IMAGE}:${TAG}', git branch: '${BRANCH}' COMPLETED."
