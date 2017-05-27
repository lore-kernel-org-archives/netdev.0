From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 1/3] net: phy: Create sysfs reciprocal links
 for attached_dev/phydev
Date: Sat, 27 May 2017 00:20:00 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A9DAF6@CHN-SV-EXMX02.mchp-main.com>
References: <20170524193354.10739-1-f.fainelli@gmail.com>
 <20170524193354.10739-2-f.fainelli@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DAA2@CHN-SV-EXMX02.mchp-main.com>
 <d2d97683-3fcc-6603-09e1-13818464de18@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DACE@CHN-SV-EXMX02.mchp-main.com>
 <44f24fbd-5093-faa2-02cd-f8d4d835b59d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <davem@davemloft.net>, <andrew@lunn.ch>
To: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa1.microchip.iphmx.com ([68.232.147.91]:35296 "EHLO
        esa1.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948880AbdE0AUC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 20:20:02 -0400
In-Reply-To: <44f24fbd-5093-faa2-02cd-f8d4d835b59d@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBPSywgSSBhbSBjb25mdXNlZCBub3cuIFlvdSBhcmUgZGVzY3JpYmluZyB3aGF0IGlzIGdvaW5n
IG9uIHdpdGggeW91cg0KPiBwbGF0Zm9ybSByaWdodD8gQ2FuIHlvdSBkZXNjcmliZSBhIGJpdCBm
dXJ0aGVyIGhlcmUgd2hhdCBpcyBoYXBwZW5pbmcNCj4gYW5kIHdpdGggd2hpY2ggdHlwZSBvZiBp
bnRlcmZhY2U/IElzIHRoaXMgd2l0aCB0aGUgQ1BVIGludGVyZmFjZSBvcg0KPiBzb21ldGhpbmc/
DQoNClllcy4gSXQncyBvbiBvdXIgcGxhdGZvcm0uDQpMaWtlIHlvdXIgcGxhdGZvcm0sIGZpeGVk
IHBoeSBpcyB1c2VkIHRvIGNvbm5lY3Qgc3dpdGNoIENQVSBwb3J0L21hc3RlciBuZXRkZXYuDQpH
TUFDIG9mIFNvQyBpcyBjYWRlbmNlL21hY2IuYyB3aXRoIGZpeGVkIHBoeSBtb2RpZmljYXRpb24u
DQoNCnN0YXRpYyBpbnQgbWFjYl9taWlfcHJvYmUoc3RydWN0IG5ldF9kZXZpY2UgKmRldikNCnsN
CgkuLi4NCglwaHlkZXYgPSBwaHlfZmluZF9maXJzdChicC0+bWlpX2J1cyk7DQoJaWYgKCFwaHlk
ZXYpIHsNCgkJcGh5ZGV2ID0gZml4ZWRfcGh5X3JlZ2lzdGVyKFBIWV9QT0xMLCAmZnBoeV9zdGF0
dXMsIC0xLCBOVUxMKTsNCgkJaWYgKElTX0VSUihwaHlkZXYpKSB7DQoJCQluZXRkZXZfZXJyKGRl
diwgIm5vIFBIWSBmb3VuZFxuIik7DQoJCQlyZXR1cm4gLUVOWElPOw0KCQl9DQoJfQ0KCS4uLg0K
V2hlbiBmYWlsZWQgdG8gZmluZCBwaHlkZXYgZnJvbSBwaHlfZmluZF9maXJzdCgpLCBpdCBmb3Jj
ZXMgdG8gZml4ZWQgcGh5Lg0KCS4uLg0KCS8qIGF0dGFjaCB0aGUgbWFjIHRvIHRoZSBwaHkgKi8N
CglyZXQgPSBwaHlfY29ubmVjdF9kaXJlY3QoZGV2LCBwaHlkZXYsICZtYWNiX2hhbmRsZV9saW5r
X2NoYW5nZSwNCgkJCQkgYnAtPnBoeV9pbnRlcmZhY2UpOw0KDQpzeXNmc19jcmVhdGVfbGluKCkg
aW5zaWRlIG9mIHBoeV9jb25uZWN0X2RpcmVjdCgpIGZhaWxzLg0KDQpXaGF0IGlzIGRyaXZlciB5
b3UgYXJlIHRlc3Rpbmc/IEkgY2FuIGNoZWNrIHRoZSBmaWxlLg0KDQpUaGFua3MuDQotIFdvb2p1
bmcNCg0K
