From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [RFC PATCH 3/5] netfilter: Allow calling into nat
 helper without skb_dst.
Date: Wed, 21 Oct 2015 12:44:14 +0200
Message-ID: <20151021104414.GB2135@salvia>
References: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
 <1445379629-112880-3-git-send-email-jrajahalme@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1445379629-112880-3-git-send-email-jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

T24gVHVlLCBPY3QgMjAsIDIwMTUgYXQgMDM6MjA6MjdQTSAtMDcwMCwgSmFybm8gUmFqYWhhbG1l
IHdyb3RlOgo+IE5BVCBjaGVja3N1bSByZWNhbGN1bGF0aW9uIGNvZGUgYXNzdW1lZCBleGlzdGVu
Y2Ugb2Ygc2tiX2RzdCwgd2hpY2gKPiBiZWNvbWVzIGEgcHJvYmxlbSBmb3IgYSBsYXRlciBwYXRj
aCBpbiB0aGUgc2VyaWVzLiAgU2ltcGxpZnkgdGhpcyBieQo+IHJlbW92aW5nIHRoZSBjaGVja3Ms
IGFzIHRoZSBjaGVja3N1bSB3aWxsIGJlIGRlYWx0IHdpdGggbGF0ZXIgaW4gdGhlCj4gc3RhY2su
CgpQbGVhc2UsIHJlc3VibWl0IG5ldGZpbHRlciBwYXRjaGVzIHRvIG5ldGZpbHRlci1kZXZlbEB2
Z2VyLmtlcm5lbC5vcmcKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KZGV2IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9vcGVudnN3
aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5mby9kZXYK
