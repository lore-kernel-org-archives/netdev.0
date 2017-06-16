From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 36/44] dma-mapping: remove
	HAVE_ARCH_DMA_SUPPORTED
Date: Fri, 16 Jun 2017 20:10:51 +0200
Message-ID: <20170616181059.19206-37-hch@lst.de>
References: <20170616181059.19206-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-kernel@vger.kernel.org
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org,
 xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
 linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
 linux-mips@linux-mips.org, openrisc@lists.librecores.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
 linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
 linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org,
 netdev@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <20170616181059.19206-1-hch@lst.de>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

U2lnbmVkLW9mZi1ieTogQ2hyaXN0b3BoIEhlbGx3aWcgPGhjaEBsc3QuZGU+Ci0tLQogaW5jbHVk
ZS9saW51eC9kbWEtbWFwcGluZy5oIHwgMiAtLQogMSBmaWxlIGNoYW5nZWQsIDIgZGVsZXRpb25z
KC0pCgpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9kbWEtbWFwcGluZy5oIGIvaW5jbHVkZS9s
aW51eC9kbWEtbWFwcGluZy5oCmluZGV4IGE1Nzg3NTMwOWJmZC4uM2U1OTA4NjU2MjI2IDEwMDY0
NAotLS0gYS9pbmNsdWRlL2xpbnV4L2RtYS1tYXBwaW5nLmgKKysrIGIvaW5jbHVkZS9saW51eC9k
bWEtbWFwcGluZy5oCkBAIC01NDksNyArNTQ5LDYgQEAgc3RhdGljIGlubGluZSBpbnQgZG1hX21h
cHBpbmdfZXJyb3Ioc3RydWN0IGRldmljZSAqZGV2LCBkbWFfYWRkcl90IGRtYV9hZGRyKQogCXJl
dHVybiAwOwogfQogCi0jaWZuZGVmIEhBVkVfQVJDSF9ETUFfU1VQUE9SVEVECiBzdGF0aWMgaW5s
aW5lIGludCBkbWFfc3VwcG9ydGVkKHN0cnVjdCBkZXZpY2UgKmRldiwgdTY0IG1hc2spCiB7CiAJ
Y29uc3Qgc3RydWN0IGRtYV9tYXBfb3BzICpvcHMgPSBnZXRfZG1hX29wcyhkZXYpOwpAQCAtNTYw
LDcgKzU1OSw2IEBAIHN0YXRpYyBpbmxpbmUgaW50IGRtYV9zdXBwb3J0ZWQoc3RydWN0IGRldmlj
ZSAqZGV2LCB1NjQgbWFzaykKIAkJcmV0dXJuIDE7CiAJcmV0dXJuIG9wcy0+ZG1hX3N1cHBvcnRl
ZChkZXYsIG1hc2spOwogfQotI2VuZGlmCiAKICNpZm5kZWYgSEFWRV9BUkNIX0RNQV9TRVRfTUFT
Swogc3RhdGljIGlubGluZSBpbnQgZG1hX3NldF9tYXNrKHN0cnVjdCBkZXZpY2UgKmRldiwgdTY0
IG1hc2spCi0tIAoyLjExLjAKCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fXwpYZW4tZGV2ZWwgbWFpbGluZyBsaXN0Clhlbi1kZXZlbEBsaXN0cy54ZW4ub3Jn
Cmh0dHBzOi8vbGlzdHMueGVuLm9yZy94ZW4tZGV2ZWwK
