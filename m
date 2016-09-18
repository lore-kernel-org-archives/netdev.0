From: pravin shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH v2 1/2] openvswitch: fix flow stats accounting
 when node 0 is not possible
Date: Sat, 17 Sep 2016 19:06:27 -0700
Message-ID: <CAOrHB_D8rgEMi_yZc5wRXUiHeHqLHV89HVX29OfFd9xjDzRQuQ@mail.gmail.com>
References: <1473977513-7617-1-git-send-email-cascardo@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Thadeu Lima de Souza Cascardo <cascardo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

T24gVGh1LCBTZXAgMTUsIDIwMTYgYXQgMzoxMSBQTSwgVGhhZGV1IExpbWEgZGUgU291emEgQ2Fz
Y2FyZG8KPGNhc2NhcmRvQHJlZGhhdC5jb20+IHdyb3RlOgo+IE9uIGEgc3lzdGVtIHdpdGggb25s
eSBub2RlIDEgYXMgcG9zc2libGUsIGFsbCBzdGF0aXN0aWNzIGlzIGdvaW5nIHRvIGJlCj4gYWNj
b3VudGVkIG9uIG5vZGUgMCBhcyBpdCB3aWxsIGhhdmUgYSBzaW5nbGUgd3JpdGVyLgo+Cj4gSG93
ZXZlciwgd2hlbiBnZXR0aW5nIGFuZCBjbGVhcmluZyB0aGUgc3RhdGlzdGljcywgbm9kZSAwIGlz
IG5vdCBnb2luZwo+IHRvIGJlIGNvbnNpZGVyZWQsIGFzIGl0J3Mgbm90IGEgcG9zc2libGUgbm9k
ZS4KPgo+IFRlc3RlZCB0aGF0IHN0YXRpc3RpY3MgYXJlIG5vdCB6ZXJvIG9uIGEgc3lzdGVtIHdp
dGggb25seSBub2RlIDEKPiBwb3NzaWJsZS4gQWxzbyBjb21waWxlLXRlc3RlZCB3aXRoIENPTkZJ
R19OVU1BIG9mZi4KPgo+IFNpZ25lZC1vZmYtYnk6IFRoYWRldSBMaW1hIGRlIFNvdXphIENhc2Nh
cmRvIDxjYXNjYXJkb0ByZWRoYXQuY29tPgoKQWNrZWQtYnk6IFByYXZpbiBCIFNoZWxhciA8cHNo
ZWxhckBvdm4ub3JnPgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dp
dGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
