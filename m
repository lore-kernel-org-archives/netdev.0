From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 2/9] libnl: nla_put_le64(): align on
 a 64-bit area
Date: Mon, 25 Apr 2016 09:41:51 +0200
Message-ID: <571DCA3F.3040403@6wind.com>
References: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461339084-3849-3-git-send-email-nicolas.dichtel@6wind.com>
 <1461343880.7627.34.camel@edumazet-glaptop3.roam.corp.google.com>
 <60b94d1a-23a2-ec18-7f2b-2ba21946af03@pengutronix.de>
 <9d534571-916d-b368-a398-7f03a1f512ec@pengutronix.de>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org,
 herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org,
 kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <9d534571-916d-b368-a398-7f03a1f512ec-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

TGUgMjMvMDQvMjAxNiAxOToyOCwgQWxleGFuZGVyIEFyaW5nIGEgw6ljcml0IDoKPgo+IEhpLAo+
Cj4gT24gMDQvMjMvMjAxNiAwNzowNSBQTSwgQWxleGFuZGVyIEFyaW5nIHdyb3RlOgo+IC4uLgo+
Pgo+PiBpZiB0aGlzIGlzIHJlYWxseSBuZWVkZWQsIHRoZW4gbmxhX3B1dF91NjQvYmU2NC9ldGMg
bmVlZCB0byBiZSBjaGFuZ2VkIGFsc28sCj4KPiBPa2F5LCBJIGZvdW5kIFBBVENIIDMvOSBkbyBp
dCBmb3IgYmU2NCwgYnV0IHdoYXQncyBhYm91dCB1NjQ/Ckl0J3MgYWxzbyBwbGFubmVkLiBJIHdp
bGwgc2VuZCBzZXZlcmFsICJzbWFsbCIgc2VyaWVzIHRvIGVhc2UgaW50ZWdyYXRpb24uCgoKUmVn
YXJkcywKTmljb2xhcwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dp
dGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
