From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 10/11] rtlwifi: don't add include path for rtl8188ee
Date: Wed, 15 Jun 2016 17:45:52 +0200
Message-ID: <20160615154553.3177021-11-arnd@arndb.de>
References: <20160615154553.3177021-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Arnd Bergmann <arnd@arndb.de>, linux-kbuild@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-arm-kernel@lists.infradead.org
To: Michal Marek <mmarek@suse.com>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <20160615154553.3177021-1-arnd@arndb.de>
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

Rm9yIHJ0bDgxODhlZSwgd2UgcGFzcyAtSWRyaXZlcnMvbmV0L3dpcmVsZXNzL3J0bHdpZmkvIHRv
IGdjYywKaG93ZXZlciB0aGF0IGRpcmVjdHkgbm8gbG9uZ2VyIGV4aXN0cywgc28gZXZpZGVudGx5
IHRoaXMgb3B0aW9uCmlzIG5vIGxvbmdlciByZXF1aXJlZCBoZXJlIGFuZCBjYW4gYmUgcmVtb3Zl
ZCB0byBhdm9pZCBhIHdhcm5pbmcKd2hlbiBidWlsZGluZyB3aXRoICdtYWtlIFc9MScgb3IgJ2dj
YyAtV21pc3NpbmctaW5jbHVkZS1kaXJzJwoKU2lnbmVkLW9mZi1ieTogQXJuZCBCZXJnbWFubiA8
YXJuZEBhcm5kYi5kZT4KLS0tCiBkcml2ZXJzL25ldC93aXJlbGVzcy9yZWFsdGVrL3J0bHdpZmkv
cnRsODE4OGVlL01ha2VmaWxlIHwgMiArLQogMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCsp
LCAxIGRlbGV0aW9uKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvd2lyZWxlc3MvcmVhbHRl
ay9ydGx3aWZpL3J0bDgxODhlZS9NYWtlZmlsZSBiL2RyaXZlcnMvbmV0L3dpcmVsZXNzL3JlYWx0
ZWsvcnRsd2lmaS9ydGw4MTg4ZWUvTWFrZWZpbGUKaW5kZXggYTg1NDE5YTM3NjUxLi42NzZlN2Rl
MjdmMjcgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L3dpcmVsZXNzL3JlYWx0ZWsvcnRsd2lmaS9y
dGw4MTg4ZWUvTWFrZWZpbGUKKysrIGIvZHJpdmVycy9uZXQvd2lyZWxlc3MvcmVhbHRlay9ydGx3
aWZpL3J0bDgxODhlZS9NYWtlZmlsZQpAQCAtMTIsNCArMTIsNCBAQCBydGw4MTg4ZWUtb2JqcyA6
PQkJXAogCiBvYmotJChDT05GSUdfUlRMODE4OEVFKSArPSBydGw4MTg4ZWUubwogCi1jY2ZsYWdz
LXkgKz0gLUlkcml2ZXJzL25ldC93aXJlbGVzcy9ydGx3aWZpIC1EX19DSEVDS19FTkRJQU5fXwor
Y2NmbGFncy15ICs9IC1EX19DSEVDS19FTkRJQU5fXwotLSAKMi45LjAKCl9fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRyaS1kZXZlbCBtYWlsaW5nIGxpc3QK
ZHJpLWRldmVsQGxpc3RzLmZyZWVkZXNrdG9wLm9yZwpodHRwczovL2xpc3RzLmZyZWVkZXNrdG9w
Lm9yZy9tYWlsbWFuL2xpc3RpbmZvL2RyaS1kZXZlbAo=
