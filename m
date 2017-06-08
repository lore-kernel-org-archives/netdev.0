From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 32/44] hexagon: remove the unused
	dma_is_consistent prototype
Date: Thu,  8 Jun 2017 15:25:57 +0200
Message-ID: <20170608132609.32662-33-hch@lst.de>
References: <20170608132609.32662-1-hch@lst.de>
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
In-Reply-To: <20170608132609.32662-1-hch@lst.de>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

U2lnbmVkLW9mZi1ieTogQ2hyaXN0b3BoIEhlbGx3aWcgPGhjaEBsc3QuZGU+Ci0tLQogYXJjaC9o
ZXhhZ29uL2luY2x1ZGUvYXNtL2RtYS1tYXBwaW5nLmggfCAxIC0KIDEgZmlsZSBjaGFuZ2VkLCAx
IGRlbGV0aW9uKC0pCgpkaWZmIC0tZ2l0IGEvYXJjaC9oZXhhZ29uL2luY2x1ZGUvYXNtL2RtYS1t
YXBwaW5nLmggYi9hcmNoL2hleGFnb24vaW5jbHVkZS9hc20vZG1hLW1hcHBpbmcuaAppbmRleCA5
YzE1Y2I1MjcxYTYuLjQ2M2RiYzE4Zjg1MyAxMDA2NDQKLS0tIGEvYXJjaC9oZXhhZ29uL2luY2x1
ZGUvYXNtL2RtYS1tYXBwaW5nLmgKKysrIGIvYXJjaC9oZXhhZ29uL2luY2x1ZGUvYXNtL2RtYS1t
YXBwaW5nLmgKQEAgLTM3LDcgKzM3LDYgQEAgc3RhdGljIGlubGluZSBjb25zdCBzdHJ1Y3QgZG1h
X21hcF9vcHMgKmdldF9hcmNoX2RtYV9vcHMoc3RydWN0IGJ1c190eXBlICpidXMpCiAJcmV0dXJu
IGRtYV9vcHM7CiB9CiAKLWV4dGVybiBpbnQgZG1hX2lzX2NvbnNpc3RlbnQoc3RydWN0IGRldmlj
ZSAqZGV2LCBkbWFfYWRkcl90IGRtYV9oYW5kbGUpOwogZXh0ZXJuIHZvaWQgZG1hX2NhY2hlX3N5
bmMoc3RydWN0IGRldmljZSAqZGV2LCB2b2lkICp2YWRkciwgc2l6ZV90IHNpemUsCiAJCQkgICBl
bnVtIGRtYV9kYXRhX2RpcmVjdGlvbiBkaXJlY3Rpb24pOwogCi0tIAoyLjExLjAKCgpfX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpYZW4tZGV2ZWwgbWFpbGlu
ZyBsaXN0Clhlbi1kZXZlbEBsaXN0cy54ZW4ub3JnCmh0dHBzOi8vbGlzdHMueGVuLm9yZy94ZW4t
ZGV2ZWwK
