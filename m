From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: [PATCH net] atl1e: drop pci-msi support because of packet
 corruption
Date: Fri, 29 Mar 2013 05:03:43 +0000
Message-ID: <157393863283F442885425D2C45428564F2022D0@nasanexd02f.na.qualcomm.com>
References: <20130329041050.GA29040@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "rebelyouth.hacklab@gmail.com" <rebelyouth.hacklab@gmail.com>,
	"christian.suenkenberg@student.kit.edu"
	<christian.suenkenberg@student.kit.edu>,
	"sven@svenhartge.de" <sven@svenhartge.de>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth02.qualcomm.com ([65.197.215.38]:6476 "EHLO
	sabertooth02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247Ab3C2FDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 01:03:45 -0400
In-Reply-To: <20130329041050.GA29040@order.stressinduktion.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogSGFubmVzIEZyZWRlcmlj
IFNvd2EgW21haWx0bzpoYW5uZXNAc3RyZXNzaW5kdWt0aW9uLm9yZ10NCj4gU2VudDogRnJpZGF5
LCBNYXJjaCAyOSwgMjAxMyAxMjoxMSBQTQ0KPiBUbzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZw0K
PiBDYzogcmViZWx5b3V0aC5oYWNrbGFiQGdtYWlsLmNvbTsgSHVhbmcsIFhpb25nOw0KPiBjaHJp
c3RpYW4uc3VlbmtlbmJlcmdAc3R1ZGVudC5raXQuZWR1OyBzdmVuQHN2ZW5oYXJ0Z2UuZGUNCj4g
U3ViamVjdDogW1BBVENIIG5ldF0gYXRsMWU6IGRyb3AgcGNpLW1zaSBzdXBwb3J0IGJlY2F1c2Ug
b2YgcGFja2V0DQo+IGNvcnJ1cHRpb24NCj4gDQo+IFVzYWdlIG9mIHBjaS1tc2kgcmVzdWx0cyBp
biBjb3JydXB0ZWQgZG1hIHBhY2tldCB0cmFuc2ZlcnMgdG8gdGhlIGhvc3QuDQo+IA0KPiBSZXBv
cnRlZC1ieTogcmViZWx5b3V0aCA8cmViZWx5b3V0aC5oYWNrbGFiQGdtYWlsLmNvbT4NCj4gQ2M6
IEh1YW5nLCBYaW9uZyA8eGlvbmdAcWNhLnF1YWxjb21tLmNvbT4NCj4gVGVzdGVkLWJ5OiBDaHJp
c3RpYW4gU8O8bmtlbmJlcmcgPGNocmlzdGlhbi5zdWVua2VuYmVyZ0BzdHVkZW50LmtpdC5lZHU+
DQo+IFNpZ25lZC1vZmYtYnk6IEhhbm5lcyBGcmVkZXJpYyBTb3dhIDxoYW5uZXNAc3RyZXNzaW5k
dWt0aW9uLm9yZz4NCj4gLS0tDQo+IEkgdGhpbmsgdGhpcyBpcyBtYXRlcmlhbCBmb3IgLXN0YWJs
ZS4NCj4gDQpIaSAgSGFubmVzLCANCg0KeW91IGNhbiB0cnkgdG8gZW5hYmxlIHJ4LWNoZWNrc3Vt
IG9mZmxvYWQgaWYgRE1BIGlzc3VlIGRpc2FwcGVhciwgYXMgd2luZG93cyBkcml2ZXIgZW5hYmxl
IHRoaXMgZmVhdHVyZS4NCg0KDQpUaGFua3MNCi1YaW9uZw0KDQo=
