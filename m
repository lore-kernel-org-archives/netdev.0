From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 0/8] netlink: align attributes when
 needed (patchset #3)
Date: Tue, 26 Apr 2016 12:02:24 -0400 (EDT)
Message-ID: <20160426.120224.155123476886174129.davem@davemloft.net>
References: <1461657978-13360-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, sd-y1jBWg8GRStKuXlAQpz2QA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 jack-IBi9RG/b67k@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org,
 lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1461657978-13360-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
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

RnJvbTogTmljb2xhcyBEaWNodGVsIDxuaWNvbGFzLmRpY2h0ZWxANndpbmQuY29tPgpEYXRlOiBU
dWUsIDI2IEFwciAyMDE2IDEwOjA2OjEwICswMjAwCgo+IFRoZSBsYXN0IHVzZXIgb2YgbmxhX3B1
dF91NjQoKSBpcyBibG9jay9kcmJkLiBUaGlzIG1vZHVsZSBkb2VzIG5vdCB1c2UKPiBzdGFuZGFy
ZCBuZXRsaW5rIEFQSSAoc2VlIGFsbCB0aGUgc3R1ZmYgaW4gaW5jbHVkZS9saW51eC9nZW5sX21h
Z2ljX3N0cnVjdC5oCj4gYW5kIGluY2x1ZGUvbGludXgvZ2VubF9tYWdpY19mdW5jLmgpLgoKWWV0
IGFub3RoZXIgZXhhbXBsZSB3aGVyZSBkb2luZyB0aGluZ3MgaW4gYSBzcGVjaWFsIHVuaXF1ZSB3
YXkgY3JlYXRlcwpoZWFkYWNoZXMgYW5kIHBhaW4gZm9yIGV2ZXJ5b25lLi4uIHNpZ2guCgo+IEkg
ZGlkbid0IG1vZGlmeSBpdCBiZWNhdXNlIGl0J3Mgc2VlbXMgaGFyZCB0byBkbyBpdCB3aGl0aG91
dCB0ZXN0aW5nCj4gYW5kIGZ1bGx5IHVuZGVyc3RhbmRpbmcgdGhlIGNvbnRleHQgKGZvciBleGFt
cGxlLCB3aHkKPiBpbmNsdWRlL2xpbnV4L2RyYmRfZ2VubC5oIGlzIG5vdCBwYXJ0IG9mIHVhcGk/
KS4gIEFueSB0aG91Z2h0cz8KCkkgdGhpbmsgeW91J2xsIG5lZWQgdG8gd29yayB3aXRoIHRoZSBk
cmJkIG1haW50YWluZXIocykgdG8gcmVzb2x2ZQp0aGlzIGFuZCB0ZXN0IHRoZSByZXN1bHQuCgpT
ZXJpZXMgYXBwbGllZCwgdGhhbmtzLgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDov
L29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
