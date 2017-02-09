From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] xen-netfront: Improve error handling
 during initialization
Date: Thu, 09 Feb 2017 16:46:55 -0500 (EST)
Message-ID: <20170209.164655.35358163111689337.davem@davemloft.net>
References: <1486551457-25963-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: jgross@suse.com, wei.liu2@citrix.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
 boris.ostrovsky@oracle.com
To: ross.lagerwall@citrix.com
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1486551457-25963-1-git-send-email-ross.lagerwall@citrix.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

RnJvbTogUm9zcyBMYWdlcndhbGwgPHJvc3MubGFnZXJ3YWxsQGNpdHJpeC5jb20+CkRhdGU6IFdl
ZCwgOCBGZWIgMjAxNyAxMDo1NzozNyArMDAwMAoKPiBUaGlzIGZpeGVzIGEgY3Jhc2ggd2hlbiBy
dW5uaW5nIG91dCBvZiBncmFudCByZWZzIHdoZW4gY3JlYXRpbmcgbWFueQo+IHF1ZXVlcyBhY3Jv
c3MgbWFueSBuZXRkZXZzLgo+IAo+ICogSWYgY3JlYXRpbmcgcXVldWVzIGZhaWxzIChpLmUuIHRo
ZXJlIGFyZSBubyBncmFudCByZWZzIGF2YWlsYWJsZSksCj4gY2FsbCB4ZW5idXNfZGV2X2ZhdGFs
KCkgdG8gZW5zdXJlIHRoYXQgdGhlIHhlbmJ1cyBkZXZpY2UgaXMgc2V0IHRvIHRoZQo+IGNsb3Nl
ZCBzdGF0ZS4KPiAqIElmIG5vIHF1ZXVlcyBhcmUgY3JlYXRlZCwgZG9uJ3QgY2FsbCB4ZW5uZXRf
ZGlzY29ubmVjdF9iYWNrZW5kIGFzCj4gbmV0ZGV2LT5yZWFsX251bV90eF9xdWV1ZXMgd2lsbCBu
b3QgaGF2ZSBiZWVuIHNldCBjb3JyZWN0bHkuCj4gKiBJZiBzZXR1cF9uZXRmcm9udCgpIGZhaWxz
LCBlbnN1cmUgdGhhdCBhbGwgdGhlIHF1ZXVlcyBjcmVhdGVkIGFyZQo+IGNsZWFuZWQgdXAsIG5v
dCBqdXN0IHRob3NlIHRoYXQgaGF2ZSBiZWVuIHNldCB1cC4KPiAqIElmIGFueSBxdWV1ZXMgd2Vy
ZSBzZXQgdXAgYW5kIGFuIGVycm9yIG9jY3VycywgY2FsbAo+IHhlbm5ldF9kZXN0cm95X3F1ZXVl
cygpIHRvIGNsZWFuIHVwIHRoZSBuYXBpIGNvbnRleHQuCj4gKiBJZiBhbnkgZmF0YWwgZXJyb3Ig
b2NjdXJzLCB1bnJlZ2lzdGVyIGFuZCBkZXN0cm95IHRoZSBuZXRkZXYgdG8gYXZvaWQKPiBsZWF2
aW5nIGFyb3VuZCBhIGhhbGYgc2V0dXAgbmV0d29yayBkZXZpY2UuCj4gCj4gU2lnbmVkLW9mZi1i
eTogUm9zcyBMYWdlcndhbGwgPHJvc3MubGFnZXJ3YWxsQGNpdHJpeC5jb20+CgpBcHBsaWVkLgoK
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KWGVuLWRldmVs
IG1haWxpbmcgbGlzdApYZW4tZGV2ZWxAbGlzdHMueGVuLm9yZwpodHRwczovL2xpc3RzLnhlbi5v
cmcveGVuLWRldmVsCg==
