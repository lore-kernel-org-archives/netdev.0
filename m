From: "=?UTF-8?Q?H=C3=A5kon_L=C3=B8vdal?=" <hlovdal@gmail.com>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sat, 31 May 2008 23:45:56 +0200
Message-ID: <a01a16b50805311445g23ea825t809fbace49f16d0d@mail.gmail.com>
References: <20080526115628.GA31316@elte.hu> <1211966834.12349.62.camel@twins>
	 <a01a16b50805310725x4f1c375ep2d091bb044ac0787@mail.gmail.com>
	 <Pine.LNX.4.64.0805311839540.2657@wrl-59.cs.helsinki.fi>
	 <484191BD.8000904@gmail.com>
	 <Pine.LNX.4.64.0805312119270.2672@wrl-59.cs.helsinki.fi>
	 <a01a16b50805311325w7f58ca69h93d02af9bc28d2ea@mail.gmail.com>
	 <Pine.LNX.4.64.0805312332270.2760@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, "Ingo Molnar" <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "=?UTF-8?Q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:45620 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894AbYEaVp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 17:45:57 -0400
Received: by rv-out-0506.google.com with SMTP id l9so414334rvb.1
        for <netdev@vger.kernel.org>; Sat, 31 May 2008 14:45:56 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0805312332270.2760@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MjAwOC81LzMxIElscG8gSsOkcnZpbmVuIDxpbHBvLmphcnZpbmVuQGhlbHNpbmtpLmZpPjoKPiBP
biBTYXQsIDMxIE1heSAyMDA4LCBIw6Vrb24gTMO4dmRhbCB3cm90ZToKPj4gMjAwOC81LzMxIEls
cG8gSsOkcnZpbmVuIDxpbHBvLmphcnZpbmVuQGhlbHNpbmtpLmZpPjoKPj4gPiBTbyB5b3UgaGFk
IHRoYXQgJy0nIGVhcmxpZXIgYW5kIHlvdSBjaGVja2VkIGF0IHRoYXQgdGltZSBidXQgdGhlCj4+
ID4gY29ubmVjdGlvbiBpcyBub3cgYWxyZWFkeSBkZWFkPwo+Pgo+PiBUaGlzIGlzIG9ubHkgZnJv
bSBjaGVja2luZyBhZnRlciB0aGUgY29ubmVjdGlvbiB3YXMgZGVhZC4KPgo+IENvdWxkIHlvdSBw
bGVhc2UgcmVwaHJhc2UgdGhlIGFuc3dlciwgSSBmYWlsZWQgdG8gdW5kZXJzdGFuZCBpdC4uLiA6
LSkKPiAuLi5Zb3Ugc2FpZCBlYXJsaWVyIHRoYXQgeW91IGhhZCAnLScgb3duZWQgY29ubmVjdGlv
bnMgbGlrZSBJbmdvLCB3aGVuIGRpZAo+IHRoYXQgaGFwcGVuIChub3cgdGhlIGNvbm5lY3Rpb25z
IHdvbid0IGV4aXN0cyBhbnltb3JlLCBzbyBhdCB3aGF0IHBvaW50IG9mCj4gdGltZSB5b3Ugc2F3
IHRob3NlIG5vbi1vd25lZCBjb25uZWN0aW9ucyk/CgpXaGF0IEkgbWVhbiBpcyB0aGF0IEkganVz
dCB0ZXN0ZWQgIm5ldHN0YXQgLXAiIGFuZCBub3RpY2VkIHNpbWlsYXJpdGllcwp3aXRoIEluZ28n
cyByZXN1bHQgdG9kYXkgd2hpbGUgcmVwbHlpbmcgdG8gdGhpcyB0aHJlYWQsIHdoaWNoIGlzIGRh
eXMKYWZ0ZXIgdGhlIGNvbm5lY3Rpb25zIGVuZGVkLgoKQlIgSMOla29uIEzDuHZkYWwK
