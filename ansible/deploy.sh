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

if [[ "${OCP_CLUSTER}" == @('certprod') ]]; then
    oc image mirror "${IMAGE_IN_NEXUS}:${TAG}" "${IMAGE_IN_QUAY}:${TAG}" --insecure=true --skip-mount=true --force=true
    err_check "${?}" "Failed to mirror image '${IMAGE_IN_NEXUS}:${TAG}' -> '${IMAGE_IN_QUAY}:${TAG}'."
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
    -e "s|%IMAGE%|${IMAGE}|g" \
    -e "s|%TAG%|${TAG}|g"
err_check "${?}" "One of the sed inline replacements failed."
cat k8s.app.template.yaml
TMPL=$(oc process -f k8s.app.template.yaml)
oc create -f - <<< "${TMPL}" || oc apply -f - <<< "${TMPL}"
err_check "${?}" "Failed either to create new or update existing k8s resources template from k8s.app.template.yaml."
echo "Deploying service '${SVC_NAME}' to namespace '${NAMESPACE}' (of '${OCP_CLUSTER}' OpensShift) from image '${IMAGE}:${TAG}', git branch: '${BRANCH}' COMPLETED."
