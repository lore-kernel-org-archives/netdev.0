From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 0/9] netlink: align attributes when
 needed (patchset #1)
Date: Sat, 23 Apr 2016 20:13:59 -0400 (EDT)
Message-ID: <20160423.201359.395973791059696609.davem@davemloft.net>
References: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org,
 herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
 yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1461339084-3849-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
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

RnJvbTogTmljb2xhcyBEaWNodGVsIDxuaWNvbGFzLmRpY2h0ZWxANndpbmQuY29tPgpEYXRlOiBG
cmksIDIyIEFwciAyMDE2IDE3OjMxOjE1ICswMjAwCgo+IFRoaXMgaXMgdGhlIGNvbnRpbnVhdGlv
biBvZiB0aGUgd29yayBkb25lIHRvIGFsaWduIG5ldGxpbmsgYXR0cmlidXRlcwo+IHdoZW4gdGhl
c2UgYXR0cmlidXRlcyBjb250YWluIHNvbWUgNjQtYml0IGZpZWxkcy4KPiAKPiBEYXZpZCwgaWYg
dGhlIHRoaXJkIHBhdGNoIGlzIHRvbyBiaWcgKG9yIG1heWJlIHRoZSBzZXJpZXMpLCBJIGNhbiBz
cGxpdCBpdC4KPiBKdXN0IHRlbGwgbWUgd2hhdCB5b3UgcHJlZmVyLgoKVGhpcyBsb29rcyBleGNl
bGxlbnQsIHNlcmllcyBhcHBsaWVkLCB0aGFua3MhCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9y
ZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
