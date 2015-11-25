From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 06/16] i40e: Properly cast type for arithmetic
Date: Wed, 25 Nov 2015 10:55:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBDC03B@AcuExch.aculab.com>
References: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1448409886-90686-7-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1448412212.20113.12.camel@perches.com> <1448448411.3154.32.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Helin Zhang <helin.zhang@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
	Joe Perches <joe@perches.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.195]:61821 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbbKYK5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 05:57:18 -0500
In-Reply-To: <1448448411.3154.32.camel@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSmVmZiBLaXJzaGVyDQo+IFNlbnQ6IDI1IE5vdmVtYmVyIDIwMTUgMTA6NDcNCj4gT24g
VHVlLCAyMDE1LTExLTI0IGF0IDE2OjQzIC0wODAwLCBKb2UgUGVyY2hlcyB3cm90ZToNCj4gPiBP
biBUdWUsIDIwMTUtMTEtMjQgYXQgMTY6MDQgLTA4MDAsIEplZmYgS2lyc2hlciB3cm90ZToNCj4g
PiA+IEZyb206IEhlbGluIFpoYW5nIDxoZWxpbi56aGFuZ0BpbnRlbC5jb20+DQo+ID4gPg0KPiA+
ID4gUG9pbnRlciBvZiB0eXBlIHZvaWQgKiBzaG91bGRuJ3QgYmUgdXNlZCBpbiBhcml0aG1ldGlj
LCB3aGljaCBtYXkNCj4gPiA+IHJlc3VsdCBpbiBjb21waWxhdGlvbiBlcnJvci4gQ2FzdGluZyBv
ZiAodTggKikgY2FuIGJlIGFkZGVkIHRvIGZpeA0KPiA+ID4gdGhhdC4NCj4gPiA+DQo+ID4NCj4g
PiB2b2lkICogYXJpdGhtZXRpYyBpcyB1c2VkIHF1aXRlIGZyZXF1ZW50bHkgaW4gdGhlIGtlcm5l
bC4NCj4gPg0KPiA+IFdoYXQgY29tcGlsZXIgZW1pdHMgYW4gZXJyb3I/DQo+IA0KPiBXaGVuIHlv
dSB1c2UgdGhlIGdjYyAtV3BvaW50ZXItYXJpdGgsIGl0IGdlbmVyYXRlcyB0aGUgd2FybmluZy4N
Cg0KRG9uJ3QgZG8gdGhhdCB0aGVuIDotKQ0KUmlnaHRmdWxseSBvciBub3QgdGhlIExpbnV4IGtl
cm5lbCByZXF1aXJlcyAndm9pZCAqJyBhcml0aG1ldGljLg0KDQoJRGF2aWQNCg0K
