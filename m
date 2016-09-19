From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 1/2] openvswitch: fix flow stats accounting
 when node 0 is not possible
Date: Sun, 18 Sep 2016 22:14:14 -0400 (EDT)
Message-ID: <20160918.221414.54746725722771424.davem@davemloft.net>
References: <1473977513-7617-1-git-send-email-cascardo@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: cascardo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1473977513-7617-1-git-send-email-cascardo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

RnJvbTogVGhhZGV1IExpbWEgZGUgU291emEgQ2FzY2FyZG8gPGNhc2NhcmRvQHJlZGhhdC5jb20+
CkRhdGU6IFRodSwgMTUgU2VwIDIwMTYgMTk6MTE6NTIgLTAzMDAKCj4gT24gYSBzeXN0ZW0gd2l0
aCBvbmx5IG5vZGUgMSBhcyBwb3NzaWJsZSwgYWxsIHN0YXRpc3RpY3MgaXMgZ29pbmcgdG8gYmUK
PiBhY2NvdW50ZWQgb24gbm9kZSAwIGFzIGl0IHdpbGwgaGF2ZSBhIHNpbmdsZSB3cml0ZXIuCj4g
Cj4gSG93ZXZlciwgd2hlbiBnZXR0aW5nIGFuZCBjbGVhcmluZyB0aGUgc3RhdGlzdGljcywgbm9k
ZSAwIGlzIG5vdCBnb2luZwo+IHRvIGJlIGNvbnNpZGVyZWQsIGFzIGl0J3Mgbm90IGEgcG9zc2li
bGUgbm9kZS4KPiAKPiBUZXN0ZWQgdGhhdCBzdGF0aXN0aWNzIGFyZSBub3QgemVybyBvbiBhIHN5
c3RlbSB3aXRoIG9ubHkgbm9kZSAxCj4gcG9zc2libGUuIEFsc28gY29tcGlsZS10ZXN0ZWQgd2l0
aCBDT05GSUdfTlVNQSBvZmYuCj4gCj4gU2lnbmVkLW9mZi1ieTogVGhhZGV1IExpbWEgZGUgU291
emEgQ2FzY2FyZG8gPGNhc2NhcmRvQHJlZGhhdC5jb20+CgpBcHBsaWVkIHRvIG5ldC1uZXh0Lgpf
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkZXYgbWFpbGlu
ZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9tYWlsbWFu
L2xpc3RpbmZvL2Rldgo=
