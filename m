From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2 v3] ipv4: Cache dst in tunnels
Date: Fri, 03 Jan 2014 19:42:33 -0500 (EST)
Message-ID: <20140103.194233.1475063659612788745.davem@davemloft.net>
References: <alpine.DEB.2.02.1401021139500.32654@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbaADAme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 19:42:34 -0500
In-Reply-To: <alpine.DEB.2.02.1401021139500.32654@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVG9tIEhlcmJlcnQgPHRoZXJiZXJ0QGdvb2dsZS5jb20+DQpEYXRlOiBUaHUsIDIgSmFu
IDIwMTQgMTE6NDg6MTggLTA4MDAgKFBTVCkNCg0KPiBWZXJzaW9uIDMgb2YgY2FjaGluZyByb3V0
ZXMgaW4gdHVubmVscy4NCg0KQXBwbGllZCwgYnV0IEkgcmVhbGx5IGhhdmUgdG8gd29uZGVyIHdo
ZW4gSSBoYXZlIHRvIGZpeCB1cCB0aGluZ3MgbGlrZQ0KdGhpczoNCg0KbmV0L2lwdjQvaXBfdHVu
bmVsLmM6IEluIGZ1bmN0aW9uIKFpcF90dW5uZWxfaW5pdKI6DQpuZXQvaXB2NC9pcF90dW5uZWwu
YzoxMDYyOjIwOiB3YXJuaW5nOiBhc3NpZ25tZW50IGZyb20gaW5jb21wYXRpYmxlIHBvaW50ZXIg
dHlwZSBbZW5hYmxlZCBieSBkZWZhdWx0XQ0KDQotLT4NCg0KLS0tIGEvbmV0L2lwdjQvaXBfdHVu
bmVsLmMNCisrKyBiL25ldC9pcHY0L2lwX3R1bm5lbC5jDQpAQCAtMTA1OSw3ICsxMDU5LDcgQEAg
aW50IGlwX3R1bm5lbF9pbml0KHN0cnVjdCBuZXRfZGV2aWNlICpkZXYpDQogCQl1NjRfc3RhdHNf
aW5pdCgmaXB0X3N0YXRzLT5zeW5jcCk7DQogCX0NCiANCi0JdHVubmVsLT5kc3RfY2FjaGUgPSBh
bGxvY19wZXJjcHUoc3RydWN0IGlwX3R1bm5lbF9kc3QgKik7DQorCXR1bm5lbC0+ZHN0X2NhY2hl
ID0gYWxsb2NfcGVyY3B1KHN0cnVjdCBpcF90dW5uZWxfZHN0KTsNCiAJaWYgKCF0dW5uZWwtPmRz
dF9jYWNoZSkgew0KIAkJZnJlZV9wZXJjcHUoZGV2LT50c3RhdHMpOw0KIAkJcmV0dXJuIC1FTk9N
RU07DQo=
