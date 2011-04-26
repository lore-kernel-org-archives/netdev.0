From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 4/7] sctp: remove useless arguments from
 get_saddr() call
Date: Tue, 26 Apr 2011 00:20:20 -0700 (PDT)
Message-ID: <20110426.002020.48493363.davem@davemloft.net>
References: <4DB63F85.2090609@cn.fujitsu.com>
	<4DB6405B.2060200@cn.fujitsu.com>
	<20110426.001227.112589346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49739
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757513Ab1DZHUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 03:20:54 -0400
In-Reply-To: <20110426.001227.112589346.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAyNiBB
cHIgMjAxMSAwMDoxMjoyNyAtMDcwMCAoUERUKQ0KDQo+IEkgcmVhbGx5IGdldCBncnVtcHkgd2hl
biBJIGhhdmUgdG8gZml4IHVwIHN0dWZmIGxpa2UgdGhpczoNCj4gDQo+IG5ldC9zY3RwL2lwdjYu
YzogSW4gZnVuY3Rpb24goXNjdHBfdjZfZ2V0X3NhZGRyojoNCj4gbmV0L3NjdHAvaXB2Ni5jOjM4
Mjogd2FybmluZzogdW51c2VkIHZhcmlhYmxlIKFkYWRkcqINCg0KTm93IEknbSBldmVuIG1vcmUg
Z3J1bXB5LCBpZiBJIG9ubHkgYXBwbHkgdGhlIGZpcnN0IDMgcGF0Y2hlczoNCg0KbmV0L3NjdHAv
aXB2Ni5jOiBJbiBmdW5jdGlvbiChc2N0cF92Nl9kc3RfbG9va3VwojoNCm5ldC9zY3RwL2lwdjYu
YzoyNTk6IHdhcm5pbmc6IGFzc2lnbm1lbnQgbWFrZXMgaW50ZWdlciBmcm9tIHBvaW50ZXIgd2l0
aG91dCBhIGNhc3QNCg0KaXQgZ29lcyBhd2F5IGxhdGVyIGJ1dCB5b3UncmUgbm90IHRlc3Rpbmcg
dGhlIGludGVybWVkaWF0ZSBzdGVwcw0Kb2YgeW91ciBTQ1RQIHBhdGNoIGJhY2twb3J0cyBhbmQg
YXMgYSByZXN1bHQgeW91IGFyZSBnb2luZyB0bw0KYnJlYWsgYmlzZWN0aW5nLg0KDQpJJ20gcmV2
ZXJ0aW5nIHRoaXMgcGF0Y2ggc2VyaWVzLCBmaXggdGhpcyB1cCBhbmQgYWN0dWFsbHkgdGVzdA0K
dGhlIGludGVybWVkaWF0ZSBidWlsZHMgYW5kIGZ1bmN0aW9uYWxpdHkgYmVmb3JlIHJlc3VibWlz
c2lvbi4NCg0K
