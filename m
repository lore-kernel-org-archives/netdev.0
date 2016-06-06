From: Zhao Qiang <qiang.zhao@nxp.com>
Subject: [Patch v3 3/5] fsl/qe: Make regs resouce_size_t
Date: Mon, 6 Jun 2016 14:30:00 +0800
Message-ID: <1465194602-43209-3-git-send-email-qiang.zhao@nxp.com>
References: <1465194602-43209-1-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, Zhao Qiang <qiang.zhao@nxp.com>,
 linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 xiaobo.xie@nxp.com
To: <oss@buserror.net>, <davem@davemloft.net>, <Joakim.Tjernlund@infinera.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1465194602-43209-1-git-send-email-qiang.zhao@nxp.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

U2lnbmVkLW9mZi1ieTogWmhhbyBRaWFuZyA8cWlhbmcuemhhb0BueHAuY29tPgotLS0KQ2hhbmdl
cyBmb3IgdjI6CgktIG1vZGlmeSBzdWJqZWN0CkNoYW5nZXMgZm9yIHYzOgoJLSBuYQoKIGluY2x1
ZGUvc29jL2ZzbC9xZS91Y2NfZmFzdC5oIHwgMiArLQogMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0
aW9uKCspLCAxIGRlbGV0aW9uKC0pCgpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9zb2MvZnNsL3FlL3Vj
Y19mYXN0LmggYi9pbmNsdWRlL3NvYy9mc2wvcWUvdWNjX2Zhc3QuaAppbmRleCBiMjYzM2I3Li5l
ODk4ODk1IDEwMDY0NAotLS0gYS9pbmNsdWRlL3NvYy9mc2wvcWUvdWNjX2Zhc3QuaAorKysgYi9p
bmNsdWRlL3NvYy9mc2wvcWUvdWNjX2Zhc3QuaApAQCAtMTIzLDcgKzEyMyw3IEBAIHN0cnVjdCB1
Y2NfZmFzdF9pbmZvIHsKIAllbnVtIHFlX2Nsb2NrIHR4X2Nsb2NrOwogCWVudW0gcWVfY2xvY2sg
cnhfc3luYzsKIAllbnVtIHFlX2Nsb2NrIHR4X3N5bmM7Ci0JdTMyIHJlZ3M7CisJcmVzb3VyY2Vf
c2l6ZV90IHJlZ3M7CiAJaW50IGlycTsKIAl1MzIgdWNjbV9tYXNrOwogCWludCBiZF9tZW1fcGFy
dDsKLS0gCjIuMS4wLjI3Lmc5NmRiMzI0CgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXwpMaW51eHBwYy1kZXYgbWFpbGluZyBsaXN0CkxpbnV4cHBjLWRldkBs
aXN0cy5vemxhYnMub3JnCmh0dHBzOi8vbGlzdHMub3psYWJzLm9yZy9saXN0aW5mby9saW51eHBw
Yy1kZXY=
