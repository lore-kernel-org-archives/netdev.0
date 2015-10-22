From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net v3] openvswitch: Allocate memory for ovs
 internal device stats.
Date: Wed, 21 Oct 2015 19:07:28 -0700 (PDT)
Message-ID: <20151021.190728.758804935928190351.davem@davemloft.net>
References: <1445268715-21661-1-git-send-email-james.morse@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: james.morse-5wv7dgnIgG8@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1445268715-21661-1-git-send-email-james.morse-5wv7dgnIgG8@public.gmane.org>
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

RnJvbTogSmFtZXMgTW9yc2UgPGphbWVzLm1vcnNlQGFybS5jb20+CkRhdGU6IE1vbiwgMTkgT2N0
IDIwMTUgMTY6MzE6NTUgKzAxMDAKCj4gIm9wZW52c3dpdGNoOiBSZW1vdmUgdnBvcnQgc3RhdHMi
IHJlbW92ZWQgdGhlIHBlci12cG9ydCBzdGF0aXN0aWNzLCBpbgo+IG9yZGVyIHRvIHVzZSB0aGUg
bmV0ZGV2J3Mgc3RhdGlzdGljcyBmaWVsZHMuCj4gIm9wZW52c3dpdGNoOiBGaXggb3ZzX3Zwb3J0
X2dldF9zdGF0cygpIiBmaXhlZCB0aGUgZXhwb3J0IG9mIHRoZXNlIHN0YXRzCj4gdG8gdXNlci1z
cGFjZSwgYnkgdXNpbmcgdGhlIHByb3ZpZGVkIG5ldGRldl9vcHMgdG8gY29sbGF0ZSB0aGVtIC0g
YnV0IG92cwo+IGludGVybmFsIGRldmljZXMgc3RpbGwgdXNlIGFuIHVuYWxsb2NhdGVkIGRldi0+
dHN0YXRzIGZpZWxkIHRvIGNvdW50Cj4gcGFja2V0cywgd2hpY2ggYXJlIG5vIGxvbmdlciBleHBv
cnRlZCBieSB0aGlzIGFwaS4KPiAKPiBBbGxvY2F0ZSB0aGUgZGV2LT50c3RhdHMgZmllbGQgZm9y
IG92cyBpbnRlcm5hbCBkZXZpY2VzLCBhbmQgd2lyZSB1cAo+IG5kb19nZXRfc3RhdHM2NCB3aXRo
IHRoZSBvcmlnaW5hbCBpbXBsZW1lbnRhdGlvbiBvZgo+IG92c192cG9ydF9nZXRfc3RhdHMoKS4K
PiAKPiBPbiBpdHMgb3duLCAib3BlbnZzd2l0Y2g6IEZpeCBvdnNfdnBvcnRfZ2V0X3N0YXRzKCki
IGZpeGVzIHRoZSBPT1BzLAo+IHVubWFza2luZyBhIGZ1bGwtb24gcGFuaWMgb24gYXJtNjQ6Ci4u
Lgo+IEZpeGVzOiA4Yzg3NjYzOWM5ODUgKCJvcGVudnN3aXRjaDogUmVtb3ZlIHZwb3J0IHN0YXRz
LiIpCj4gU2lnbmVkLW9mZi1ieTogSmFtZXMgTW9yc2UgPGphbWVzLm1vcnNlQGFybS5jb20+CgpB
cHBsaWVkLCB0aGFua3MuCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZz
d2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
