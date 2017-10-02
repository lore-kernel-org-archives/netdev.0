From: Laurentiu Tudor <laurentiu.tudor@nxp.com>
Subject: Re: [RESEND PATCH 2/6] staging: fsl-dpaa2/ethsw: Add Freescale DPAA2
 Ethernet Switch driver
Date: Mon, 2 Oct 2017 09:32:29 +0000
Message-ID: <59D20766.5040606@nxp.com>
References: <1505825158-8192-1-git-send-email-razvan.stefanescu@nxp.com>
 <1505825158-8192-3-git-send-email-razvan.stefanescu@nxp.com>
 <DB5PR04MB12400025DF190790B4792B50EA7E0@DB5PR04MB1240.eurprd04.prod.outlook.com>
 <AM3PR04MB0743F62497ED0CB445F51524E67E0@AM3PR04MB0743.eurprd04.prod.outlook.com>
 <A4C4732A-CC1F-4707-89F8-E7284F022DB0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "agraf@suse.de" <agraf@suse.de>, "arnd@arndb.de" <arnd@arndb.de>,
        Alexandru Marginean <alexandru.marginean@nxp.com>,
        Ruxandra Ioana Radulescu <ruxandra.radulescu@nxp.com>,
        "stuyoder@gmail.com" <stuyoder@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Razvan Stefanescu <razvan.stefanescu@nxp.com>,
        Bogdan Purcareata <bogdan.purcareata@nxp.com>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <A4C4732A-CC1F-4707-89F8-E7284F022DB0@gmail.com>
Content-Language: en-US
Content-ID: <4F2DC13F0E627643A3EB18410E999D50@eurprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SGkgRmxvcmlhbiwNCg0KT24gMDkvMjkvMjAxNyAwNzoxMSBQTSwgRmxvcmlhbiBGYWluZWxsaSB3
cm90ZToNCj4gT24gU2VwdGVtYmVyIDI5LCAyMDE3IDY6NTk6MTggQU0gUERULCBSYXp2YW4gU3Rl
ZmFuZXNjdSA8cmF6dmFuLnN0ZWZhbmVzY3VAbnhwLmNvbT4gd3JvdGU6DQo+Pg0KPj4NCj4+PiAt
LS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPj4+IEZyb206IEJvZ2RhbiBQdXJjYXJlYXRhDQo+
Pj4gU2VudDogRnJpZGF5LCBTZXB0ZW1iZXIgMjksIDIwMTcgMTY6MzYNCj4+PiBUbzogUmF6dmFu
IFN0ZWZhbmVzY3UgPHJhenZhbi5zdGVmYW5lc2N1QG54cC5jb20+Ow0KPj4+IGdyZWdraEBsaW51
eGZvdW5kYXRpb24ub3JnDQo+Pj4gQ2M6IGRldmVsQGRyaXZlcmRldi5vc3Vvc2wub3JnOyBsaW51
eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOw0KPj4+IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IGFn
cmFmQHN1c2UuZGU7IGFybmRAYXJuZGIuZGU7IEFsZXhhbmRydQ0KPj4gTWFyZ2luZWFuDQo+Pj4g
PGFsZXhhbmRydS5tYXJnaW5lYW5AbnhwLmNvbT47IFJ1eGFuZHJhIElvYW5hIFJhZHVsZXNjdQ0K
Pj4+IDxydXhhbmRyYS5yYWR1bGVzY3VAbnhwLmNvbT47IExhdXJlbnRpdSBUdWRvcg0KPj4gPGxh
dXJlbnRpdS50dWRvckBueHAuY29tPjsNCj4+PiBzdHV5b2RlckBnbWFpbC5jb20NCj4+PiBTdWJq
ZWN0OiBSRTogW1JFU0VORCBQQVRDSCAyLzZdIHN0YWdpbmc6IGZzbC1kcGFhMi9ldGhzdzogQWRk
DQo+PiBGcmVlc2NhbGUgRFBBQTINCj4+PiBFdGhlcm5ldCBTd2l0Y2ggZHJpdmVyDQo+Pj4NCj4+
Pj4gSW50cm9kdWNlIHRoZSBEUEFBMiBFdGhlcm5ldCBTd2l0Y2ggZHJpdmVyLCB3aGljaCBtYW5h
Z2VzIERhdGFwYXRoDQo+PiBTd2l0Y2gNCj4+Pj4gKERQU1cpIG9iamVjdHMgZGlzY292ZXJlZCBv
biB0aGUgTUMgYnVzLg0KPj4+Pg0KPj4+PiBTdWdnZXN0ZWQtYnk6IEFsZXhhbmRydSBNYXJnaW5l
YW4gPGFsZXhhbmRydS5tYXJnaW5lYW5AbnhwLmNvbT4NCj4+Pj4gU2lnbmVkLW9mZi1ieTogUmF6
dmFuIFN0ZWZhbmVzY3UgPHJhenZhbi5zdGVmYW5lc2N1QG54cC5jb20+DQo+DQo+IFRoaXMgbG9v
a3MgcHJldHR5IGdvb2QgZm9yIGEgbmV3IHN3aXRjaGRldiBkcml2ZXIsIGlzIHRoZXJlIGEgcmVh
c29uIHlvdSBjYW4ndCB0YXJnZXQgZHJpdmVycy9uZXQvZXRoZXJuZXQgaW5zdGVhZCBvZiBzdGFn
aW5nPyBJcyBpdCBiZWNhdXNlIHRoZSBNQyBidXMgY29kZSBpcyBzdGlsbCBpbiBzdGFnaW5nIChB
RkFJQ1QpPw0KDQpUaGVyZSdzIGEgcGVuZGluZyBwYXRjaCBbMV0gdGhhdCBtb3ZlcyB0aGUgYnVz
IGZyb20gc3RhZ2luZyB0byBpdHMgcGxhY2UgDQppbiBkcml2ZXJzL2J1cy4gRFBJTyBwbHVzIG90
aGVyIGJpdHMgYW5kIHBpZWNlcyBhcmUgbmV4dCBvbiB0aGUgbGlzdC4NCg0KR3JlZywNCg0KSnVz
dCBhIGhlYWRzIHVwOiBpZiB0aGlzIGRyaXZlciBnb2VzIGluIGZpcnN0LCB0aGVuIGknbGwgbmVl
ZCB0byByZS1zcGluIA0KbXkgcGF0Y2ggWzFdIHRvIGFsc28gdXBkYXRlIHRoZSAjaW5jbHVkZSdz
IGluIHRoaXMgc3dpdGNoIGRyaXZlci4NCg0KUC5TLiBBbnkgbmV3cyBvbiBteSBwYXRjaD8gOi0p
DQoNClsxXSBodHRwczovL3d3dy5zcGluaWNzLm5ldC9saXN0cy9hcm0ta2VybmVsL21zZzYwMzUz
NC5odG1sDQoNCi0tLQ0KVGhhbmtzLCBMYXVyZW50aXU=
