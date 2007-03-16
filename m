From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 1/2] [KBUILD]: Unifdef headers changed by the skb layer header refactorings
Date: Fri, 16 Mar 2007 00:04:28 -0300
Message-ID: <39e6f6c70703152004y53f10d4fm9a2a8092cc6288be@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_71764_32643397.1174014268350"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:33752 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848AbXCPDEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2007 23:04:30 -0400
Received: by ug-out-1314.google.com with SMTP id 44so569118uga
        for <netdev@vger.kernel.org>; Thu, 15 Mar 2007 20:04:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_71764_32643397.1174014268350
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/linux/Kbuild |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

------=_Part_71764_32643397.1174014268350
Content-Type: text/x-patch;
	name=0001-KBUILD-Unifdef-headers-changed-by-the-skb-layer-h.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ezc1ou18
Content-Disposition: attachment; filename="0001-KBUILD-Unifdef-headers-changed-by-the-skb-layer-h.patch"

RnJvbSAyM2Y5NDI2YzUxMTU3YmY2NWQ5MmQzOGI0ZDBiZjQzNjRjMjc4ODc3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogVGh1LCAxNSBNYXIgMjAwNyAyMTowODo1NSAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMS8yXSBbS0JVSUxEXTogVW5pZmRlZiBoZWFkZXJzIGNoYW5nZWQgYnkgdGhlIHNrYiBsYXll
ciBoZWFkZXIgcmVmYWN0b3JpbmdzCgpTaWduZWQtb2ZmLWJ5OiBBcm5hbGRvIENhcnZhbGhvIGRl
IE1lbG8gPGFjbWVAcmVkaGF0LmNvbT4KLS0tCiBpbmNsdWRlL2xpbnV4L0tidWlsZCB8ICAgIDYg
KysrLS0tCiAxIGZpbGVzIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgMyBkZWxldGlvbnMoLSkK
CmRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L0tidWlsZCBiL2luY2x1ZGUvbGludXgvS2J1aWxk
CmluZGV4IGU4MWUzMDEuLmVhODZmMmUgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvS2J1aWxk
CisrKyBiL2luY2x1ZGUvbGludXgvS2J1aWxkCkBAIC02OSw5ICs2OSw3IEBAIGhlYWRlci15ICs9
IGhkc21hcnQuaAogaGVhZGVyLXkgKz0gaHlzZG5faWYuaAogaGVhZGVyLXkgKz0gaTJjLWRldi5o
CiBoZWFkZXIteSArPSBpOGsuaAotaGVhZGVyLXkgKz0gaWNtcC5oCiBoZWFkZXIteSArPSBpZl9h
cmNuZXQuaAotaGVhZGVyLXkgKz0gaWZfYXJwLmgKIGhlYWRlci15ICs9IGlmX2JvbmRpbmcuaAog
aGVhZGVyLXkgKz0gaWZfY2FibGVtb2RlbS5oCiBoZWFkZXIteSArPSBpZl9mYy5oCkBAIC04OCw3
ICs4Niw2IEBAIGhlYWRlci15ICs9IGlmX3R1bm5lbC5oCiBoZWFkZXIteSArPSBpbjYuaAogaGVh
ZGVyLXkgKz0gaW5fcm91dGUuaAogaGVhZGVyLXkgKz0gaW9jdGwuaAotaGVhZGVyLXkgKz0gaXAu
aAogaGVhZGVyLXkgKz0gaXBtaV9tc2dkZWZzLmgKIGhlYWRlci15ICs9IGlwX21wX2FsZy5oCiBo
ZWFkZXIteSArPSBpcHNlYy5oCkBAIC0yMTAsOCArMjA3LDEwIEBAIHVuaWZkZWYteSArPSBoaWRk
ZXYuaAogdW5pZmRlZi15ICs9IGhwZXQuaAogdW5pZmRlZi15ICs9IGkyYy5oCiB1bmlmZGVmLXkg
Kz0gaTJvLWRldi5oCit1bmlmZGVmLXkgKz0gaWNtcC5oCiB1bmlmZGVmLXkgKz0gaWNtcHY2LmgK
IHVuaWZkZWYteSArPSBpZl9hZGRyLmgKK3VuaWZkZWYteSArPSBpZl9hcnAuaAogdW5pZmRlZi15
ICs9IGlmX2JyaWRnZS5oCiB1bmlmZGVmLXkgKz0gaWZfZWMuaAogdW5pZmRlZi15ICs9IGlmX2Vx
bC5oCkBAIC0yMzEsNiArMjMwLDcgQEAgdW5pZmRlZi15ICs9IGluZXRfZGlhZy5oCiB1bmlmZGVm
LXkgKz0gaW4uaAogdW5pZmRlZi15ICs9IGlub3RpZnkuaAogdW5pZmRlZi15ICs9IGlucHV0LmgK
K3VuaWZkZWYteSArPSBpcC5oCiB1bmlmZGVmLXkgKz0gaXBjLmgKIHVuaWZkZWYteSArPSBpcG1p
LmgKIHVuaWZkZWYteSArPSBpcHY2LmgKLS0gCjEuNS4wLjMKCg==
------=_Part_71764_32643397.1174014268350--
