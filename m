From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 04/22] bnx2x: Separate VF and PF logic
Date: Sun, 30 Dec 2012 17:35:13 -0800 (PST)
Message-ID: <20121230.173513.545111396374915524.davem@davemloft.net>
References: <1356897442-3063-1-git-send-email-ariele@broadcom.com>
	<1356897442-3063-5-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47374 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755279Ab2LaBfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 20:35:16 -0500
In-Reply-To: <1356897442-3063-5-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogIkFyaWVsIEVsaW9yIiA8YXJpZWxlQGJyb2FkY29tLmNvbT4NCkRhdGU6IFN1biwgMzAg
RGVjIDIwMTIgMjE6NTc6MDQgKzAyMDANCg0KPiBHZW5lcmFsbHksIHRoZSBWRiBkcml2ZXIgY2Fu
bm90IGFjY2VzcyB0aGUgY2hpcCwgZXhjZXB0IGJ5IHRoZQ0KPiBuYXJyb3cgd2luZG93IGl0cyBC
QVIgYWxsb3dzLiBDYXJlIGhhZCB0byBiZSB0YWtlbiBzbyB0aGUgVkYgZHJpdmVyDQo+IHdpbGwg
bm90IHJlYWNoIGNvZGUgd2hpY2ggYWNjZXNzZXMgdGhlIGNoaXAgZWxzZXdoZXJlLg0KPiBSZWZh
Y3RvciB0aGUgbmljX2xvYWQgZmxvdyBpbnRvIHBhcnRzIHNvIGl0IHdvdWxkIGJlDQo+IGVhc2ll
ciB0byBzZXBhcmF0ZSB0aGUgVkYtb25seSBsb2dpYyBmcm9tIHRoZSBQRi1vbmx5IGxvZ2ljLg0K
PiANCj4gU2lnbmVkLW9mZi1ieTogQXJpZWwgRWxpb3IgPGFyaWVsZUBicm9hZGNvbS5jb20+DQo+
IFNpZ25lZC1vZmYtYnk6IEVpbG9uIEdyZWVuc3RlaW4gPGVpbG9uZ0Bicm9hZGNvbS5jb20+DQoN
ClRoaXMgaW50cm9kdWNlcyB3YXJuaW5nczoNCg0KZHJpdmVycy9uZXQvZXRoZXJuZXQvYnJvYWRj
b20vYm54MngvYm54MnhfbWFpbi5jOiBJbiBmdW5jdGlvbiChYm54Mnhfb3BlbqI6DQpkcml2ZXJz
L25ldC9ldGhlcm5ldC9icm9hZGNvbS9ibngyeC9ibngyeF9tYWluLmM6MTEzMTE6Nzogd2Fybmlu
ZzogoWxvYWRfc3RhdHVzoiBtYXkgYmUgdXNlZCB1bmluaXRpYWxpemVkIGluIHRoaXMgZnVuY3Rp
b24gWy1XbWF5YmUtdW5pbml0aWFsaXplZF0NCmRyaXZlcnMvbmV0L2V0aGVybmV0L2Jyb2FkY29t
L2JueDJ4L2JueDJ4X21haW4uYzoxMTMxMjoxODogd2FybmluZzogoW90aGVyX2xvYWRfc3RhdHVz
oiBtYXkgYmUgdXNlZCB1bmluaXRpYWxpemVkIGluIHRoaXMgZnVuY3Rpb24gWy1XbWF5YmUtdW5p
bml0aWFsaXplZF0NCg0KVGhpcyBpcyB3aXRoIGdjYy00LjcuMiBvbiBGZWRvcmEgMTcNCg==
