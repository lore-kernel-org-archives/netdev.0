From: Joe Stringer <joestringer-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv10 ovs 03/15] datapath: Add 'is_mask' to
	ovs_nla_put_flow().
Date: Thu, 20 Nov 2014 16:15:24 -0800
Message-ID: <CANr6G5x4ObV4r3G1wLd+51nr=oYtwt=ConknjO29VkNT-vvrmA@mail.gmail.com>
References: <1415906275-3172-1-git-send-email-joestringer@nicira.com>
 <1415906275-3172-4-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1415906275-3172-4-git-send-email-joestringer-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

T24gMTMgTm92ZW1iZXIgMjAxNCAxMToxNywgSm9lIFN0cmluZ2VyIDxqb2VzdHJpbmdlckBuaWNp
cmEuY29tPiB3cm90ZToKPiBUaGlzIGZ1bmN0aW9uIHByZXZpb3VzbHkgaGlkIHRoZSAnaXNfbWFz
aycgcGFyYW1ldGVyIGZyb20gdGhlIGNhbGxlcnMsCj4gd2hpY2ggYWN0dWFsbHkgaGF2ZSBiZXR0
ZXIga25vd2xlZGdlIGFib3V0IHdoZXRoZXIgaXQgaXMgc2VyaWFsaXppbmcgYQo+IG1hc2sgb3Ig
bm90LiBFeHBvc2UgdGhpcyBwYXJhbWV0ZXIgdG8gdGhlIGNhbGxlcnMuIFRoaXMgYWxsb3dzIHRo
ZSBzYW1lCj4gZnVuY3Rpb24gdG8gYmUgY2FsbGVkIHRvIHNlcmlhbGl6ZSBtYXNrZWQga2V5cyBh
cyB3ZWxsIGFzIG1hc2tlZCBrZXlzLgo+Cj4gVG8gc2VyaWFsaXplIGFuIHVubWFza2VkIGtleToK
PiBvdnNfbmxhX3B1dF9mbG93KGtleSwga2V5LCBza2IsIGZhbHNlKTsKPgo+IFRvIHNlcmlhbGl6
ZSBhIG1hc2tlZCBrZXk6Cj4gb3ZzX25sYV9wdXRfZmxvdyhtYXNrLCBrZXksIHNrYiwgZmFsc2Up
Owo+Cj4gVG8gc2VyaWFsaXplIGEgbWFzazoKPiBvdnNfbmxhX3B1dF9mbG93KGtleSwgbWFzaywg
c2tiLCB0cnVlKTsKCkknbGwgYWRkIGhlbHBlcnMgZm9yIGVhY2ggb2YgdGhlc2UgZnVuY3Rpb25z
OgpvdnNfbmxhX3B1dF97dW4sfW1hc2tlZF9rZXkoKSwgb3ZzX25sYV9wdXRfbWFzaygpIGluIHRo
ZSBuZXh0IHZlcnNpb24uCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZz
d2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
