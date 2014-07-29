From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: Re: [PATCH 3/9] i40e: use correct structure type name in sizeof
Date: Tue, 29 Jul 2014 20:22:20 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B73369BF3@ORSMSX104.amr.corp.intel.com>
References: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
 <1406647011-8543-4-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>,
	"ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>,
	"toralf.foerster@gmx.de" <toralf.foerster@gmx.de>,
	"hmh@hmh.eng.br" <hmh@hmh.eng.br>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
To: "Julia.Lawall@lip6.fr" <Julia.Lawall@lip6.fr>
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <1406647011-8543-4-git-send-email-Julia.Lawall@lip6.fr>
Content-Language: en-US
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gVHVlLCAyMDE0LTA3LTI5IGF0IDE3OjE2ICswMjAwLCBKdWxpYSBMYXdhbGwgd3JvdGU6Cj4g
RnJvbTogSnVsaWEgTGF3YWxsIDxKdWxpYS5MYXdhbGxAbGlwNi5mcj4KPiAKPiBDb3JyZWN0IHR5
cG8gaW4gdGhlIG5hbWUgb2YgdGhlIHR5cGUgZ2l2ZW4gdG8gc2l6ZW9mLiAgQmVjYXVzZSBpdCBp
cyB0aGUKPiBzaXplIG9mIGEgcG9pbnRlciB0aGF0IGlzIHdhbnRlZCwgdGhlIHR5cG8gaGFzIG5v
IGltcGFjdCBvbiBjb21waWxhdGlvbiBvcgo+IGV4ZWN1dGlvbi4KPiAKPiBUaGlzIHByb2JsZW0g
d2FzIGZvdW5kIHVzaW5nIENvY2NpbmVsbGUgKGh0dHA6Ly9jb2NjaW5lbGxlLmxpcDYuZnIvKS4g
IFRoZQo+IHNlbWFudGljIHBhdGNoIHVzZWQgY2FuIGJlIGZvdW5kIGluIG1lc3NhZ2UgMCBvZiB0
aGlzIHBhdGNoIHNlcmllcy4KPiAKPiBTaWduZWQtb2ZmLWJ5OiBKdWxpYSBMYXdhbGwgPEp1bGlh
Lkxhd2FsbEBsaXA2LmZyPgo+IAo+IC0tLQo+ICBkcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9p
NDBlL2k0MGVfbWFpbi5jIHwgICAgMiArLQo+ICAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24o
KyksIDEgZGVsZXRpb24oLSkKClRoYW5rcyBKdWxpYSwgSSBoYXZlIGFkZGVkIHlvdXIgcGF0Y2gg
dG8gb3VyIChKZWZmJ3MpIHF1ZXVlLgo=
