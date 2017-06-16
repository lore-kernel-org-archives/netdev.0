From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 12/44] microblaze: remove DMA_ERROR_CODE
Date: Fri, 16 Jun 2017 20:10:27 +0200
Message-ID: <20170616181059.19206-13-hch@lst.de>
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
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <20170616181059.19206-1-hch@lst.de>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

bWljcm9ibGF6ZSBkb2VzIG5vdCByZXR1cm4gZXJyb3JzIGZvciBkbWFfbWFwX3BhZ2UuCgpTaWdu
ZWQtb2ZmLWJ5OiBDaHJpc3RvcGggSGVsbHdpZyA8aGNoQGxzdC5kZT4KLS0tCiBhcmNoL21pY3Jv
YmxhemUvaW5jbHVkZS9hc20vZG1hLW1hcHBpbmcuaCB8IDIgLS0KIDEgZmlsZSBjaGFuZ2VkLCAy
IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2FyY2gvbWljcm9ibGF6ZS9pbmNsdWRlL2FzbS9k
bWEtbWFwcGluZy5oIGIvYXJjaC9taWNyb2JsYXplL2luY2x1ZGUvYXNtL2RtYS1tYXBwaW5nLmgK
aW5kZXggM2ZhZDVlNzIyYTY2Li5lMTVjZDJmNzZlMjMgMTAwNjQ0Ci0tLSBhL2FyY2gvbWljcm9i
bGF6ZS9pbmNsdWRlL2FzbS9kbWEtbWFwcGluZy5oCisrKyBiL2FyY2gvbWljcm9ibGF6ZS9pbmNs
dWRlL2FzbS9kbWEtbWFwcGluZy5oCkBAIC0yOCw4ICsyOCw2IEBACiAjaW5jbHVkZSA8YXNtL2lv
Lmg+CiAjaW5jbHVkZSA8YXNtL2NhY2hlZmx1c2guaD4KIAotI2RlZmluZSBETUFfRVJST1JfQ09E
RQkJKH4oZG1hX2FkZHJfdCkweDApCi0KICNkZWZpbmUgX19kbWFfYWxsb2NfY29oZXJlbnQoZGV2
LCBnZnAsIHNpemUsIGhhbmRsZSkJTlVMTAogI2RlZmluZSBfX2RtYV9mcmVlX2NvaGVyZW50KHNp
emUsIGFkZHIpCQkoKHZvaWQpMCkKIAotLSAKMi4xMS4wCgpfX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fXwpkcmktZGV2ZWwgbWFpbGluZyBsaXN0CmRyaS1kZXZl
bEBsaXN0cy5mcmVlZGVza3RvcC5vcmcKaHR0cHM6Ly9saXN0cy5mcmVlZGVza3RvcC5vcmcvbWFp
bG1hbi9saXN0aW5mby9kcmktZGV2ZWwK
