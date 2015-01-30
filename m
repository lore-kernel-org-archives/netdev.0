From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 1/6] skbuff: Add skb_list_linearize()
Date: Fri, 30 Jan 2015 12:25:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAD6218@AcuExch.aculab.com>
References: <1422574164-1860-1-git-send-email-pshelar@nicira.com>
	<54CAFA72.60207@gmail.com>
 <CALnjE+roOJx3seVQ8Jrc-x0FRx-Hdv+x4isfUCHY0rtz8XY+YA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: 'Pravin Shelar' <pshelar@nicira.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:59805 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932485AbbA3M0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 07:26:19 -0500
In-Reply-To: <CALnjE+roOJx3seVQ8Jrc-x0FRx-Hdv+x4isfUCHY0rtz8XY+YA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogUHJhdmluIFNoZWxhcg0KLi4uDQo+ID4gSSdtIG5vdCBjb21wbGV0ZWx5IGNvbnZpbmNl
ZCB0aGlzIGlzIGV2ZW4gbmVjZXNzYXJ5LiAgU2VlbXMgbGlrZSB5b3UgYXJlDQo+ID4gd2FzdGlu
ZyBjeWNsZXMgY29weWluZyB0aGUgZnJhbWVzIGFyb3VuZCB3aGVuIHlvdSBjb3VsZCBwcm9iYWJs
eSBqdXN0DQo+ID4gcHVsbCB0aGUgaGVhZGVyIG9mIHRoZSBmaXJzdCBmcmFtZSBhbmQgdGhlbiB1
c2UgcGFnZSBmcmFnZXMgdG8gZmlsbCBpbg0KPiA+IHRoZSByZXN0Lg0KPiA+DQo+IA0KPiBUaGlz
IGlzIHdoYXQgaXMgZG9uZSB3aGVuIHBvc3NpYmxlLiBCdXQgc2tiIG1lcmdpbmcgaXMgbm90IGFs
d2F5cw0KPiBwb3NzaWJsZSwgZm9yIGV4YW1wbGUgd2hlbiAgTUFYX1NLQl9GUkFHUyBsaW1pdCBp
cyByZWFjaGVkLiBZb3UgY2FuDQo+IGhhdmUgYSBsb29rIGF0IFNUVCBpbXBsZW1lbnRhdGlvbi4N
Cg0KSWYgTUFYX1NLQl9GUkFHUyBpcyByZWFjaGVkIHdoeSBub3QganVzdCBnZW5lcmF0ZSB0d28g
ZnJhbWVzPw0KRXhjZXB0IGluIHBhdGhvbG9naWNhbCBjYXNlcyB3aXRoIGEgbG9nIG9mIHNtYWxs
IGZyYWdtZW50cw0KdGhlIGxpbmVhcml6ZSBpcyBsaWtlbHkgdG8gYmUgbW9yZSBleHBlbnNpdmUg
dGhhbiB0aGUgcHJvY2Vzc2luZy4NCg0KCURhdmlkDQoNCg==
