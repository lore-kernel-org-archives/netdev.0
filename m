From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] sierra_net: Add support for IPv6 and Dual-Stack
 Link Sense Indications
Date: Tue, 07 Feb 2017 13:55:48 -0500 (EST)
Message-ID: <20170207.135548.37750516957060303.davem@davemloft.net>
References: <20170207023317.29192-1-stefan.bruens@rwth-aachen.de>
        <94f1dec53f614c76802adf350f495922@rwthex-w2-b.rwth-ad.de>
        <20170207.135312.2024064918721070962.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: stefan.bruens@rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54582 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754141AbdBGS4m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 13:56:42 -0500
In-Reply-To: <20170207.135312.2024064918721070962.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAwNyBG
ZWIgMjAxNyAxMzo1MzoxMiAtMDUwMCAoRVNUKQ0KDQo+IEZyb206IFN0ZWZhbiBCcsO8bnMgPHN0
ZWZhbi5icnVlbnNAcnd0aC1hYWNoZW4uZGU+DQo+IERhdGU6IFR1ZSwgNyBGZWIgMjAxNyAwMzoz
MzoxNiArMDEwMA0KPiANCj4+IElmIGEgY29udGV4dCBpcyBjb25maWd1cmVkIGFzIGR1YWxzdGFj
ayAoIklQdjR2NiIpLCB0aGUgbW9kZW0gaW5kaWNhdGVzDQo+PiB0aGUgY29udGV4dCBhY3RpdmF0
aW9uIHdpdGggYSBzbGlnaHRseSBkaWZmZXJlbnQgaW5kaWNhdGlvbiBtZXNzYWdlLg0KPj4gVGhl
IGR1YWwtc3RhY2sgaW5kaWNhdGlvbiBvbWl0cyB0aGUgbGlua190eXBlIChJUHY0L3Y2KSBhbmQg
YWRkcw0KPj4gYWRkaXRpb25hbCBhZGRyZXNzIGZpZWxkcy4NCj4+IElQdjYgTFNJcyBhcmUgaWRl
bnRpY2FsIHRvIElQdjQgTFNJcywgYnV0IGhhdmUgYSBkaWZmZXJlbnQgbGluayB0eXBlLg0KPj4g
DQo+PiBTaWduZWQtb2ZmLWJ5OiBTdGVmYW4gQnLDvG5zIDxzdGVmYW4uYnJ1ZW5zQHJ3dGgtYWFj
aGVuLmRlPg0KPiANCj4gQXBwbGllZC4NCj4gDQo+IElnbm9yZSBteSBlYXJsaWVyIGNvbW1lbnRz
IGFib3V0IHRoZSBVTVRTIGNvbW1lbnQsIGl0IGlzIHN0aWxsDQo+IGFjY3VyYXRlIG9mIGNvdXJz
ZS4gOi0pDQoNCkFjdXRhbGx5LCB0aGlzIHN0aWxsIG5lZWQgd29yay4gIEkgaGFkIHRvIHJldmVy
dC4NCg0KWW91IHJlbW92ZWQgdGhlIGNvZGUgdXNpbmcgdGhlICdldGgnIHZhcmlhYmxlIGZyb20g
c2llcnJhX25ldF9iaW5kKCkgYnV0DQpsZWZ0IHRoZSB1bnVzZWQgdmFyaWFibGUgZGVjbGFyZWQu
DQoNClBsZWFzZSByZXNwaW4gdGhpcyBzZXJpZXMgd2l0aCBpdCByZW1vdmVkIHNvIHdlIGRvbid0
IGdldCB0aGUgd2FybmluZzoNCg0KZHJpdmVycy9uZXQvdXNiL3NpZXJyYV9uZXQuYzogSW4gZnVu
Y3Rpb24g4oCYc2llcnJhX25ldF9iaW5k4oCZOg0KZHJpdmVycy9uZXQvdXNiL3NpZXJyYV9uZXQu
Yzo2ODc6MTc6IHdhcm5pbmc6IHVudXNlZCB2YXJpYWJsZSDigJhldGjigJkgWy1XdW51c2VkLXZh
cmlhYmxlXQ0KICBzdHJ1Y3QgZXRoaGRyICpldGg7DQo=
