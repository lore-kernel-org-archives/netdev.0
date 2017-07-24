From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-next] liquidio: fix implicit irq include causing build
 failures
Date: Mon, 24 Jul 2017 16:26:40 -0700 (PDT)
Message-ID: <20170724.162640.2041405160174404407.davem@davemloft.net>
References: <20170723144452.16556-1-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
        derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com
To: paul.gortmaker@windriver.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170723144452.16556-1-paul.gortmaker@windriver.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogUGF1bCBHb3J0bWFrZXIgPHBhdWwuZ29ydG1ha2VyQHdpbmRyaXZlci5jb20+DQpEYXRl
OiBTdW4sIDIzIEp1bCAyMDE3IDEwOjQ0OjUyIC0wNDAwDQoNCj4gVG8gZml4DQo+IA0KPiBJbiBm
aWxlIGluY2x1ZGVkIGZyb20gZHJpdmVycy9uZXQvZXRoZXJuZXQvY2F2aXVtL2xpcXVpZGlvL29j
dGVvbl9tZW1fb3BzLmM6MjQ6MDoNCj4gZHJpdmVycy9uZXQvZXRoZXJuZXQvY2F2aXVtL2xpcXVp
ZGlvL29jdGVvbl9kZXZpY2UuaDoyMTY6MjogZXJyb3I6IGV4cGVjdGVkIHNwZWNpZmllci1xdWFs
aWZpZXItbGlzdCBiZWZvcmUgoWlycXJldHVybl90og0KPiAgIGlycXJldHVybl90ICgqcHJvY2Vz
c19pbnRlcnJ1cHRfcmVncykodm9pZCAqKTsNCj4gICBeDQo+IA0KPiBhcyBzZWVuIG9uIGFybTY0
IGFsbG1vZGNvbmZpZyBidWlsZHMuDQo+IA0KPiBDYzogRGVyZWsgQ2hpY2tsZXMgPGRlcmVrLmNo
aWNrbGVzQGNhdml1bW5ldHdvcmtzLmNvbT4NCj4gQ2M6IFNhdGFuYW5kIEJ1cmxhIDxzYXRhbmFu
ZGEuYnVybGFAY2F2aXVtbmV0d29ya3MuY29tPg0KPiBDYzogRmVsaXggTWFubHVuYXMgPGZlbGl4
Lm1hbmx1bmFzQGNhdml1bW5ldHdvcmtzLmNvbT4NCj4gQ2M6IFJhZ2h1IFZhdHNhdmF5aSA8cmFn
aHUudmF0c2F2YXlpQGNhdml1bW5ldHdvcmtzLmNvbT4NCj4gU2lnbmVkLW9mZi1ieTogUGF1bCBH
b3J0bWFrZXIgPHBhdWwuZ29ydG1ha2VyQHdpbmRyaXZlci5jb20+DQoNCkFwcGxpZWQgdG8gbmV0
LW5leHQsIHRoYW5rcy4NCg==
