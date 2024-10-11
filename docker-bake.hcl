variable "VERSION" {
  default = "7.4.33"
}

variable "FIXID" {
  default = "1"
}

group "default" {
  targets = ["nginx-php-fpm"]
}

target "nginx-php-fpm" {
    labels = {
        "cloud.opsbox.author" = "seanly"
        "cloud.opsbox.image.name" = "nginx-php-fpm"
        "cloud.opsbox.image.version" = "${VERSION}"
        "cloud.opsbox.image.fixid" = "${FIXID}"
    }
    dockerfile = "Dockerfile"
    context  = "./"
    platforms = ["linux/amd64", "linux/arm64"]
    tags = ["seanly/nginx-php-fpm:${VERSION}-${FIXID}"]
    output = ["type=image,push=true"]
}