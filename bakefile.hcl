variable "NAMESPACE" {
    default = "sos/invokeai"
}

variable "VERSION" {
    default = "0.0.0"
}

variable "CONTEXT_ROOT" {
    default = ""
}

variable "PLATFORM" {
    default = ""
}

variable "INVOKEAI_WORKING_DIR" {
    default = ""
}

variable "INVOKEAI_GIT_TARGET" {
    default = "https://github.com/invoke-ai/InvokeAI.git"
}

variable "INVOKEAI_GIT_TAG" {
    default = "main"
}

group "default" {
    targets = [
    "application",
    ]
}

target "application" {
    dockerfile = "Dockerfile"
    tags = ["${NAMESPACE}/application:${VERSION}"]
    context = "${CONTEXT_ROOT}/docker/application/${PLATFORM}"
    contexts = {
        invokeai = "${INVOKEAI_WORKING_DIR}"
    }
    target = "runtime"
    args = {
        INVOKEAI_GIT_TARGET = INVOKEAI_GIT_TARGET
        INVOKEAI_GIT_TAG = INVOKEAI_GIT_TAG
    }
}
