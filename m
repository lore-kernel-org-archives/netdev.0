From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [RFC 1/2] TCP: Renaming md5sig to auth
Date: Fri, 18 Jul 2008 18:02:13 -0700
Message-ID: <396556a20807181802r485ba08l7420fe8e010f5ddc@mail.gmail.com>
References: <396556a20805301217k293e5718h6bbf02bfe069031@europa>
	 <20080719.095249.42274173.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: "=?UTF-8?Q?YOSHIFUJI_Hideaki_/_=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?="
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:49060 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbYGSBCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 21:02:18 -0400
Received: by rv-out-0506.google.com with SMTP id k40so517745rvb.1
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 18:02:16 -0700 (PDT)
In-Reply-To: <20080719.095249.42274173.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gRnJpLCBKdWwgMTgsIDIwMDggYXQgNTo1MiBQTSwgWU9TSElGVUpJIEhpZGVha2kgLyDlkIno
l6Toi7HmmI4KPHlvc2hmdWppQGxpbnV4LWlwdjYub3JnPiB3cm90ZToKPiBTb3JyeSwgeW91IGNh
bm5vdCBzaW1wbHkgY2hhbmdlIHRoaXMuICBQbGVhc2UgI2RlZmluZSBpdCBhdCBsZWFzdC4KPiBB
bmQgd2VsbCwgYWZ0ZXIgZ2V0dGluZyAybmQgcGF0Y2gsIHlvdSBzaG91bGQgbm90IGV2ZW4gY2hh
bmdlIHRoaXMgbmFtZS4KCkkgdGhpbmsgbXkgZGlmZiBpcyBqdXN0IGJlaW5nIGNvbmZ1c2luZy4g
c3RydWN0IHRjcF9tZDVzaWcsIGJlaW5nIHBhcnQKb2YgdGhlIGtlcm5lbCBBUEksIGlzbid0IGNo
YW5nZWQgYXQgYWxsIGFmdGVyIHRoZSB0d28gcGF0Y2hlcy4gVGhlCnN0YXRlIG9mIHRoZSBjb2Rl
IGFmdGVyIGp1c3QgdGhlIGZpcnN0IHBhdGNoIGlzbid0IGNvbnNpc3RlbnQsIGl0J3MKanVzdCB0
byByZW1vdmUgbm9pc2UgZnJvbSB0aGUgc2Vjb25kIHBhdGNoLgoKRm9yIGFueSBzZWNvbmQgc3Bp
biBvZiB0aGlzIHNlcmllcyBJJ2xsIHRyeSB0byB0d2VhayB0aGUgZmlyc3QgcGF0Y2gKc28gaXQn
cyBjbGVhcmVyIHRoYXQgSSdtIG5vdCBkb2luZyBhbnl0aGluZyBjcmF6eSA7KQoKCkNoZWVycywK
CkFHTAoKLS0gCkFkYW0gTGFuZ2xleSBhZ2xAaW1wZXJpYWx2aW9sZXQub3JnIGh0dHA6Ly93d3cu
aW1wZXJpYWx2aW9sZXQub3JnCg==
