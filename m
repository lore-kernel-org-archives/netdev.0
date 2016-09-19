From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 2/2] openvswitch: use percpu flow stats
Date: Sun, 18 Sep 2016 22:14:22 -0400 (EDT)
Message-ID: <20160918.221422.792448980235933369.davem@davemloft.net>
References: <1473977513-7617-1-git-send-email-cascardo@redhat.com>
 <1473977513-7617-2-git-send-email-cascardo@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: cascardo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1473977513-7617-2-git-send-email-cascardo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
CkRhdGU6IFRodSwgMTUgU2VwIDIwMTYgMTk6MTE6NTMgLTAzMDAKCj4gSW5zdGVhZCBvZiB1c2lu
ZyBmbG93IHN0YXRzIHBlciBOVU1BIG5vZGUsIHVzZSBpdCBwZXIgQ1BVLiBXaGVuIHVzaW5nCj4g
bWVnYWZsb3dzLCB0aGUgc3RhdHMgbG9jayBjYW4gYmUgYSBib3R0bGVuZWNrIGluIHNjYWxhYmls
aXR5Lgo+IAo+IE9uIGEgRTUtMjY5MCAxMi1jb3JlIHN5c3RlbSwgdXN1YWwgdGhyb3VnaHB1dCB3
ZW50IGZyb20gfjRNcHBzIHRvCj4gfjE1TXBwcyB3aGVuIGZvcndhcmRpbmcgYmV0d2VlbiB0d28g
NDBHYkUgcG9ydHMgd2l0aCBhIHNpbmdsZSBmbG93Cj4gY29uZmlndXJlZCBvbiB0aGUgZGF0YXBh
dGguCj4gCj4gVGhpcyBoYXMgYmVlbiB0ZXN0ZWQgb24gYSBzeXN0ZW0gd2l0aCBwb3NzaWJsZSBD
UFVzIDAtNywxNi0yMy4gQWZ0ZXIKPiBtb2R1bGUgcmVtb3ZhbCwgdGhlcmUgd2VyZSBubyBjb3Jy
dXB0aW9uIG9uIHRoZSBzbGFiIGNhY2hlLgo+IAo+IFNpZ25lZC1vZmYtYnk6IFRoYWRldSBMaW1h
IGRlIFNvdXphIENhc2NhcmRvIDxjYXNjYXJkb0ByZWRoYXQuY29tPgoKQWxzbyBhcHBsaWVkIHRv
IG5ldC1uZXh0LCB0aGFua3MuCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3Bl
bnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
