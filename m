From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Wed, 23 Dec 2015 03:31:59 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2F94FFF@RTITMBSV03.realtek.com.tw>
References: <1449573462-28417-1-git-send-email-peter@lekensteyn.nl>
	 <0835B3720019904CB8F7AA43166CEEB2F8DAD9@RTITMBSV03.realtek.com.tw>
	 <20151208143305.GB18728@al>
	 <0835B3720019904CB8F7AA43166CEEB2F94D11@RTITMBSV03.realtek.com.tw>
 <1450782082.8824.23.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450782082.8824.23.camel@suse.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T2xpdmVyIE5ldWt1bSBbbWFpbHRvOm9uZXVrdW1Ac3VzZS5jb21dDQpbLi4uXQ0KPiBJdCBpcyBj
bGVhciB0byBtZSB0aGF0IHlvdSBjYW5ub3QgZ2V0IGF3YXkgd2l0aCB1c2luZyB0aGUgc2FtZSBv
cGVyYXRpb24NCj4gZm9yIHJlc3VtZSgpIGFuZCByZXNldF9yZXN1bWUoKSBpbiB5b3VyIGRyaXZl
ci4gSXQgaXMgZnVuZGFtZW50YWxseQ0KPiBpbXBvc3NpYmxlLiBGaXJtd2FyZSBjYW5ub3QgZml4
IGl0Lg0KDQpJIHdvdWxkIHRoaW5rIGhvdyB0byBmaXggaXQuDQoNCj4gU29ycnkgZm9yIHRoZSBs
ZW5ndGggb2YgdGhlIGV4cGxhbmF0aW9uLg0KDQpUaGFua3MgZm9yIHlvdXIgcmVzcG9uc2UuIEkg
aGF2ZSBzb21lIHF1ZXN0aW9ucy4gV2hhdCBhcmUgdGhlIGZsb3dzIHdoZW4NCnRoZSBzeXN0ZW0g
cmVzdW1lIGZvbGxvd3MgYSBzeXN0ZW0gc3VzcGVuZCB3aGljaCBmb2xsb3dzIGEgYXV0b3N1c3Bl
bmQ/DQpBcmUgdGhleSBhcyBmb2xsb3dpbmc/DQoNCjEuIHN1c3BlbmQoKSB3aXRoIFBNU0dfSVNf
QVVUTyBmb3IgYXV0b3N1c3BuZWQuDQoyLiBzdXNwZW5kKCkgZm9yIHN5c3RlbSBzdXNwZW5kLg0K
My4gcmVzdW1lKCkgZm9yIHN5c3RlbSByZXN1bWUuDQoNCkFuZCwgc2hvdWxkIHRoZSBkZXZpY2Ug
ZXhpc3QgYXV0b3N1c3BlbmQgYmVmb3JlICgyKT8gDQoNCkJlc3QgUmVnYXJkcywNCkhheWVzDQoN
Cg==
