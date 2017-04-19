From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] xen/9pfs: select CONFIG_XEN_XENBUS_FRONTEND
Date: Wed, 19 Apr 2017 19:06:39 +0200
Message-ID: <20170419170648.3041204-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Latchesar Ionkov <lucho@ionkov.net>,
 Stefano Stabellini <sstabellini@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
 Eric Van Hensbergen <ericvh@gmail.com>, netdev@vger.kernel.org, groug@kaod.org,
 linux-kernel@vger.kernel.org, Stefano Stabellini <stefano@aporeto.com>,
 v9fs-developer@lists.sourceforge.net, Ron Minnich <rminnich@sandia.gov>,
 xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com,
 "David S. Miller" <davem@davemloft.net>
To: Juergen Gross <jgross@suse.com>
Return-path: <xen-devel-bounces@lists.xen.org>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

QWxsIFhlbiBmcm9udGVuZHMgbmVlZCB0byBzZWxlY3QgdGhpcyBzeW1ib2wgdG8gYXZvaWQgYSBs
aW5rIGVycm9yOgoKbmV0L2J1aWx0LWluLm86IEluIGZ1bmN0aW9uIGBwOV90cmFuc194ZW5faW5p
dCc6CjooLnRleHQrMHgxNDllOWMpOiB1bmRlZmluZWQgcmVmZXJlbmNlIHRvIGBfX3hlbmJ1c19y
ZWdpc3Rlcl9mcm9udGVuZCcKCkZpeGVzOiBkNGI0MGEwMmY4MzcgKCJ4ZW4vOXBmczogYnVpbGQg
OXBmcyBYZW4gdHJhbnNwb3J0IGRyaXZlciIpClNpZ25lZC1vZmYtYnk6IEFybmQgQmVyZ21hbm4g
PGFybmRAYXJuZGIuZGU+Ci0tLQogbmV0LzlwL0tjb25maWcgfCAxICsKIDEgZmlsZSBjaGFuZ2Vk
LCAxIGluc2VydGlvbigrKQoKZGlmZiAtLWdpdCBhL25ldC85cC9LY29uZmlnIGIvbmV0LzlwL0tj
b25maWcKaW5kZXggM2YyODZmMWJkMWQzLi5lNjAxNGUwZTUxZjcgMTAwNjQ0Ci0tLSBhL25ldC85
cC9LY29uZmlnCisrKyBiL25ldC85cC9LY29uZmlnCkBAIC0yNCw2ICsyNCw3IEBAIGNvbmZpZyBO
RVRfOVBfVklSVElPCiAKIGNvbmZpZyBORVRfOVBfWEVOCiAJZGVwZW5kcyBvbiBYRU4KKwlzZWxl
Y3QgWEVOX1hFTkJVU19GUk9OVEVORAogCXRyaXN0YXRlICI5UCBYZW4gVHJhbnNwb3J0IgogCWhl
bHAKIAkgIFRoaXMgYnVpbGRzIHN1cHBvcnQgZm9yIGEgdHJhbnNwb3J0IGZvciA5cGZzIGJldHdl
ZW4KLS0gCjIuOS4wCgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KWGVuLWRldmVsIG1haWxpbmcgbGlzdApYZW4tZGV2ZWxAbGlzdHMueGVuLm9yZwpodHRw
czovL2xpc3RzLnhlbi5vcmcveGVuLWRldmVsCg==
