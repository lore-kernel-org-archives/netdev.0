From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] Be explict with what we are !'ing in
	ixgbe_sfp_config_module_task()
Date: Wed, 8 Apr 2009 19:26:08 -0700
Message-ID: <9929d2390904081926m6176d705y481085318a930087@mail.gmail.com>
References: <75761e1f53ed07c43a977d98b54d6467d8896530.1239165870.git.tony@bakeyournoodle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tony Breeds <tony@bakeyournoodle.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <75761e1f53ed07c43a977d98b54d6467d8896530.1239165870.git.tony@bakeyournoodle.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

T24gVHVlLCBBcHIgNywgMjAwOSBhdCA5OjQ0IFBNLCBUb255IEJyZWVkcyA8dG9ueUBiYWtleW91
cm5vb2RsZS5jb20+IHdyb3RlOgo+IEdDQyB3YXJuczoKPiBkcml2ZXJzL25ldC9peGdiZS9peGdi
ZV9tYWluLmM6IEluIGZ1bmN0aW9uICdpeGdiZV9zZnBfY29uZmlnX21vZHVsZV90YXNrJzoKPiBk
cml2ZXJzL25ldC9peGdiZS9peGdiZV9tYWluLmM6MzkyMDogd2FybmluZzogc3VnZ2VzdCBwYXJl
bnRoZXNlcyBhcm91bmQgb3BlcmFuZCBvZiAnIScgb3IgY2hhbmdlICcmJyB0byAnJiYnIG9yICch
JyB0byAnficKPgo+IFdoaWNoIEkgdGhpbmsgaXMgcmlnaHQuIMKgQnJhY2tldCB0byByZW1vdmUg
YW1iaWd1aXR5Lgo+Cj4gU2lnbmVkLW9mZi1ieTogVG9ueSBCcmVlZHMgPHRvbnlAYmFrZXlvdXJu
b29kbGUuY29tPgo+IC0tLQoKVGhhbmtzLCBJIHdpbGwgYWRkIGl0IHRvIG15IHF1ZXVlIG9mIGl4
Z2JlIHBhdGNoZXMuClJlbWVtYmVyIHRvIENDIG5ldGRldiBtYWlsaW5nIGxpc3QgZm9yIG5ldHdv
cmtpbmcgcGF0Y2hlcy4KCi0tIApDaGVlcnMsCkplZmYKCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpU
aGlzIFNGLm5ldCBlbWFpbCBpcyBzcG9uc29yZWQgYnk6CkhpZ2ggUXVhbGl0eSBSZXF1aXJlbWVu
dHMgaW4gYSBDb2xsYWJvcmF0aXZlIEVudmlyb25tZW50LgpEb3dubG9hZCBhIGZyZWUgdHJpYWwg
b2YgUmF0aW9uYWwgUmVxdWlyZW1lbnRzIENvbXBvc2VyIE5vdyEKaHR0cDovL3Auc2YubmV0L3Nm
dS93d3ctaWJtLWNvbQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpFMTAwMC1kZXZlbCBtYWlsaW5nIGxpc3QKRTEwMDAtZGV2ZWxAbGlzdHMuc291cmNlZm9y
Z2UubmV0Cmh0dHBzOi8vbGlzdHMuc291cmNlZm9yZ2UubmV0L2xpc3RzL2xpc3RpbmZvL2UxMDAw
LWRldmVsCg==
