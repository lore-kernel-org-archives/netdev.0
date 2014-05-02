From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: via-rhine: Drop revision property, use quirks
 instead
Date: Fri, 02 May 2014 15:56:35 -0400 (EDT)
Message-ID: <20140502.155635.1691085402453175737.davem@davemloft.net>
References: <1398859589-22346-1-git-send-email-alchark@gmail.com>
	<1398882069-28872-1-git-send-email-alchark@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: rl@hellgate.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David.Laight@ACULAB.COM, mq@suse.cz
To: alchark@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbaEBT4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 15:56:37 -0400
In-Reply-To: <1398882069-28872-1-git-send-email-alchark@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGV5IENoYXJrb3YgPGFsY2hhcmtAZ21haWwuY29tPg0KRGF0ZTogV2VkLCAzMCBB
cHIgMjAxNCAyMjoyMTowOSArMDQwMA0KDQo+IFRoaXMgYWRkcyB0d28gbmV3IGZsYWdzIHRvIHF1
aXJrcyBhbmQgdGh1cyByZW1vdmVzIHRoZSBuZWVkIHRvIGNhcnJ5DQo+IHJldmlzaW9uIGluIHJo
aW5lX3ByaXZhdGUuIEFzIGEgcmVzdWx0LCB0aGUgaW5pdCBsb2dpYyBpcyBzaW1wbGlmaWVkDQo+
IGEgYml0Lg0KPiANCj4gVGhpcyBhbHNvIGZpeGVzIGEgY29tcGlsZXIgd2FybmluZyBpbiBPRiBj
b2RlIG9uIDY0Yml0IGR1ZSB0byBwb2ludGVyDQo+IGNhc3Rpbmc6DQo+IA0KPiAgICAgICAgIGRy
aXZlcnMvbmV0L2V0aGVybmV0L3ZpYS92aWEtcmhpbmUuYzogSW4gZnVuY3Rpb24goXJoaW5lX2lu
aXRfb25lX3BsYXRmb3JtojoNCj4gICAgICAgICBkcml2ZXJzL25ldC9ldGhlcm5ldC92aWEvdmlh
LXJoaW5lLmM6MTEzMjoxMzogd2FybmluZzogY2FzdCBmcm9tIHBvaW50ZXIgdG8gaW50ZWdlciBv
ZiBkaWZmZXJlbnQgc2l6ZSBbLVdwb2ludGVyLXRvLWludC1jYXN0XQ0KPiAgICAgICAgICAgcmV2
aXNpb24gPSAodTMyKW1hdGNoLT5kYXRhOw0KPiAgICAgICAgICAgICAgICAgICAgICBeDQo+IA0K
PiBUaGF0IGNvZGUgd2FzIGFkZGVkIGluIGNvbW1pdCAyZDI4Mzg2MmRjNjJkYWVhZDlkYjBkYzg5
Y2QwZDAzNTFlOTFmNzY1DQo+ICgibmV0OiB2aWEtcmhpbmU6IGFkZCBPRiBidXMgYmluZGluZyIp
Lg0KPiANCj4gVGVzdGVkIGluIHBsYXRmb3JtIGNvbmZpZ3VyYXRpb24gb24gYSBWSUEgV004OTUw
IEFQQyBSb2NrIGJvYXJkLg0KPiANCj4gUmVwb3J0ZWQtYnk6IEphbiBNb3NreXRvIE1hdGVqa2Eg
PG1xQHN1c2UuY3o+DQo+IFNpZ25lZC1vZmYtYnk6IEFsZXhleSBDaGFya292IDxhbGNoYXJrQGdt
YWlsLmNvbT4NCg0KVGhpcyBsb29rcyBhIGxvdCBiZXR0ZXIsIGFwcGxpZWQsIHRoYW5rcy4NCg==
