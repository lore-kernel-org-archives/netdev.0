From: "Keitel, Tino (ALC NetworX GmbH)" <Tino.Keitel@alcnetworx.de>
Subject: Re: BQL support in gianfar causes network hickup
Date: Wed, 6 Feb 2013 16:20:59 +0100
Message-ID: <9AA65D849A88EB44B5D9B6A8BA098E23042DCF04C8BE@Exchange1.lawo.de>
References: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6E@Exchange1.lawo.de>
 <50AFA599.9040108@windriver.com> <loom.20121124T213422-650@post.gmane.org>
 <1353800616.2590.4562.camel@edumazet-glaptop>
 <20121126100111.GA3728@mac.home> <1353947677.7553.2.camel@edumazet-glaptop>
 <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6F@Exchange1.lawo.de>
 <1353950255.7553.6.camel@edumazet-glaptop>
 <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE70@Exchange1.lawo.de>
 <1354019816.7553.1585.camel@edumazet-glaptop>
 <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE71@Exchange1.lawo.de>
 <1354023162.7553.1708.camel@edumazet-glaptop>
 <9AA65D849A88EB44B5D9B6A8BA098E23042DCF04C8BB@Exchange1.lawo.de>
 <CAP=VYLrbFz4UBMthg+FOqc4g0jW_4=etE+jJK6YE_EaSj8cNLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tino Keitel <tino.keitel@tikei.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.lawo.de ([80.149.95.33]:26927 "EHLO mail2.lawo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756368Ab3BFPVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 10:21:03 -0500
In-Reply-To: <CAP=VYLrbFz4UBMthg+FOqc4g0jW_4=etE+jJK6YE_EaSj8cNLA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gRGksIDIwMTMtMDItMDUgYXQgMjA6NTUgLTA1MDAsIFBhdWwgR29ydG1ha2VyIHdyb3RlOgo+
IEhvdyBjcml0aWNhbCBpcyBwdHAyIGZvciB0aGlzPyAgQW5kL29yIHRoZSBwbGF0Zm9ybSBkZXRh
aWxzPyAgSSBjYW4KPiB0cnkgYW5kIHJlcHJvZHVjZSBpdCBvbiBhbiBtcGM4MzQ5IHN5c3RlbSBh
bmQvb3IgYW4gbXBjODU0OAo+IHN5c3RlbSAoYW5kIGV2ZW4gYW4gbXBjODY0MUQgc3lzdGVtKSBi
dXQgSSdkIHJhdGhlciBrbm93IHRoYXQKPiB3YXMgYSBtZWFuaW5nZnVsIGNoYXNlIGFuZCBub3Qg
YSBzbmlwZSBodW50IGJlZm9yZSBnb2luZyB0aGVyZS4KPiAKPiBTbywgaW4gdGhhdCByZXNwZWN0
LCBhICJJZiB5b3UgcnVuIHRoaXMsIHlvdSB3aWxsIGdldCB0aGlzIiB0eXBlIG9mCj4gZXJyb3Ig
bWVzc2FnZSB3b3VsZCBiZSBnb29kLiAgIEkgdW5kZXJzdGFuZCB0aGF0IG1heSBiZSB0b28KPiBp
ZGVhbGlzdGljLCB0aG91Z2guCgpIaSwKCkknbSB1c2luZyBhbiBNUEM4MzEzRVJEQiBib2FyZCBh
bmQgd2FzIGFibGUgdG8gcmVwcm9kdWNlIGl0IHdpdGggYQp2YW5pbGxhIDMuNi43IGtlcm5lbC4g
VGhlcmUgYXJlIHNvbWUgbW9kaWZpY2F0aW9ucyB0byB0aGUgZGV2aWNlIHRyZWUsCnRob3VnaC4g
SSdsbCB0cnkgdG8gcmVwcm9kdWNlIHRoaXMgd2l0aCBhcyBmZXcgY2hhbmdlcyB0byB0aGUgZGV2
aWNlCnRyZWUgYXMgcG9zc2libGUuCgpQdHAyIGlzIGNyaXRpY2FsIGZvciB0aGUgZGVzaXJlZCB1
c2UuIFNvIGZhciBJIGFsc28gb25seSB3YXMgYWJsZSB0bwpyZXByb2R1Y2UgaXQgd2l0aCB0aGlz
IHB0cDIgY2xpZW50LgoKSWYgaXQgaXMgYSBwb3NzaWJsZSBvcHRpb24gZm9yIHlvdSwgSSBjb3Vs
ZCBwcm92aWRlIGFuIGFmZmVjdGVkIGRldmljZQp0byBtYWtlIHRoZSBpc3N1ZSBlYXN5IHRvIHJl
cHJvZHVjZS4KClJlZ2FyZHMsClRpbm8KCg==
