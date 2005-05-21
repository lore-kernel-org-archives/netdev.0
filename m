From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Subject: [PATCH] tg3: new ID
Date: Sat, 21 May 2005 02:11:37 +0200
Message-ID: <ee588a540505201711437197ca@mail.gmail.com>
Reply-To: Xose Vazquez Perez <xose.vazquez@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_2428_28044994.1116634297724"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com, jgarzik@pobox.com,
        mchan@broadcom.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

------=_Part_2428_28044994.1116634297724
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Add 0x1601 as 5752M, it's a 5752 but for mobile PCs.
Stolen from Broadcom bcm5700-8.1.55 driver.

Someone forgot to add it to tg3 ;-)

(against linux-2.6.12-rc4-git4)


-thanks-

------=_Part_2428_28044994.1116634297724
Content-Type: text/x-patch; name="tg3_5752M_id.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="tg3_5752M_id.diff"

ZGlmZiAtTnVhciBvL2RyaXZlcnMvbmV0L3RnMy5jIG4vZHJpdmVycy9uZXQvdGczLmMKLS0tIG8v
ZHJpdmVycy9uZXQvdGczLmMJMjAwNS0wNS0yMSAwMTo1MDo0MC4wMDAwMDAwMDAgKzAyMDAKKysr
IG4vZHJpdmVycy9uZXQvdGczLmMJMjAwNS0wNS0yMSAwMTo0MjoyOS4wMDAwMDAwMDAgKzAyMDAK
QEAgLTIwNiw2ICsyMDYsOCBAQAogCSAgUENJX0FOWV9JRCwgUENJX0FOWV9JRCwgMCwgMCwgMFVM
IH0sCiAJeyBQQ0lfVkVORE9SX0lEX0JST0FEQ09NLCBQQ0lfREVWSUNFX0lEX1RJR09OM181NzUy
LAogCSAgUENJX0FOWV9JRCwgUENJX0FOWV9JRCwgMCwgMCwgMFVMIH0sCisJeyBQQ0lfVkVORE9S
X0lEX0JST0FEQ09NLCBQQ0lfREVWSUNFX0lEX1RJR09OM181NzUyTSwKKwkgIFBDSV9BTllfSUQs
IFBDSV9BTllfSUQsIDAsIDAsIDBVTCB9LAogCXsgUENJX1ZFTkRPUl9JRF9CUk9BRENPTSwgUENJ
X0RFVklDRV9JRF9USUdPTjNfNTc1MywKIAkgIFBDSV9BTllfSUQsIFBDSV9BTllfSUQsIDAsIDAs
IDBVTCB9LAogCXsgUENJX1ZFTkRPUl9JRF9CUk9BRENPTSwgUENJX0RFVklDRV9JRF9USUdPTjNf
NTc1M00sCmRpZmYgLU51YXIgby9pbmNsdWRlL2xpbnV4L3BjaV9pZHMuaCBuL2luY2x1ZGUvbGlu
dXgvcGNpX2lkcy5oCi0tLSBvL2luY2x1ZGUvbGludXgvcGNpX2lkcy5oCTIwMDUtMDUtMjEgMDE6
NTA6MzQuMDAwMDAwMDAwICswMjAwCisrKyBuL2luY2x1ZGUvbGludXgvcGNpX2lkcy5oCTIwMDUt
MDUtMjEgMDE6NTA6MDYuMDAwMDAwMDAwICswMjAwCkBAIC0yMDY0LDYgKzIwNjQsNyBAQAogCiAj
ZGVmaW5lIFBDSV9WRU5ET1JfSURfQlJPQURDT00JCTB4MTRlNAogI2RlZmluZSBQQ0lfREVWSUNF
X0lEX1RJR09OM181NzUyCTB4MTYwMAorI2RlZmluZSBQQ0lfREVWSUNFX0lEX1RJR09OM181NzUy
TQkweDE2MDEKICNkZWZpbmUgUENJX0RFVklDRV9JRF9USUdPTjNfNTcwMAkweDE2NDQKICNkZWZp
bmUgUENJX0RFVklDRV9JRF9USUdPTjNfNTcwMQkweDE2NDUKICNkZWZpbmUgUENJX0RFVklDRV9J
RF9USUdPTjNfNTcwMgkweDE2NDYK
------=_Part_2428_28044994.1116634297724--
