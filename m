From: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: Integration of Open vSwitch
Date: Wed, 30 Nov 2011 22:41:11 -0800
Message-ID: <4ED72187.7070502@intel.com>
References: <CAEP_g=-g5g0Z30gYBDAZ8s7ACCZSy5MLJpPDxQmmc8m1wbk3tg@mail.gmail.com>
	<20111130070011.GA32630@gondor.apana.org.au>
	<1322658891.2243.15.camel@mojatatu>
	<1322659299.2403.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	Chris Wright <chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org" <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1322659299.2403.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

T24gMTEvMzAvMjAxMSA1OjIxIEFNLCBFcmljIER1bWF6ZXQgd3JvdGU6Cj4gTGUgbWVyY3JlZGkg
MzAgbm92ZW1icmUgMjAxMSDDoCAwODoxNCAtMDUwMCwgamFtYWwgYSDDqWNyaXQgOgo+PiBPbiBX
ZWQsIDIwMTEtMTEtMzAgYXQgMTU6MDAgKzA4MDAsIEhlcmJlcnQgWHUgd3JvdGU6Cj4+Cj4+Cj4+
PiBUaGUgb3RoZXIgZmFjdG9yIEkgY29uc2lkZXJlZCBpcyBzY2FsYWJpbGl0eS4gIFRoZSBPVlMg
Y29kZSBhcyBpcwo+Pj4gaXMgbm90IHJlYWxseSBmcmllbmRseSB0byBTTVAvTlVNQSBzY2FsYWJp
bGl0eSAoYnV0IGFzIEVyaWMgcG9pbnRlZCwKPj4+IG5laXRoZXIgaXMgdGhlIGNsYXNzaWZpZXIv
YWN0aW9uIGxheWVyKS4gCj4+Cj4+IERpZCB5b3UgbWVhbiB0aGUgcWRpc2MgZnVubmVsLXRvLWlu
dGVyZmFjZSBwYXJ0IHdoaWNoIEVyaWMgaXMgaG9wZWZ1bGx5Cj4+IGdvaW5nIHRvIHdvcmsgb24g
bm93IHRoYXQgYnFsIGlzIGluPyBjbGFzc2lmaWVyL2FjdGlvbiBoYXBwZW5zIHdheQo+PiBiZWZv
cmUgdGhhdC4KPiAKPiBBY3R1YWxseSBJIGFtIHdhaXRpbmcgZm9yIEpvaG4gd29yayBvbiB0aGlz
IGFyZWEsIGJlZm9yZSB3YXN0aW5nIG15Cj4gdGltZSA7KQo+IAoKSSdsbCB0cnkgdG8gZ2V0IHRo
ZXNlIG91dCBpbiB0aGUgbmV4dCBjb3VwbGUgZGF5cy4gR290IGEgZmV3IHFkaXNjcwpydW5uaW5n
IHdpdGhvdXQgdGhlIHFkaXNjIGxvY2sgdG9kYXkuIEFmdGVyIEkgZ2V0IHNvbWUgcmVhbCBudW1i
ZXJzCmFuZCBtYWtlIHRoZW0gYXQgbGVhc3QgYSBiaXQgbW9yZSBwcmVzZW50YWJsZSBJJ2xsIHBv
c3QgdGhlbSBzbwpmb2xrcyBjYW4gbGV0IG1lIGtub3cgaWYgdGhleSB0aGluayBpdHMgdGhlIHJp
Z2h0IGFwcHJvYWNoLgoKVGhhbmtzLApKb2huLgoKCgoKCgoKX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX18KZGV2IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0
Y2gub3JnCmh0dHA6Ly9vcGVudnN3aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5mby9kZXYK
