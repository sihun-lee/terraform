provider "local" {
}

resource "local_file" "foo" {
  filename = "${path.module}/foo.txt"
  content  = data.local_file.bar.content
}

#입력 파일
data "local_file" "bar" {
    filename = "${path.module}/bar.txt"
}