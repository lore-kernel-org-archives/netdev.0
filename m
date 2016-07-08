From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] (resend) ixgbe: always initialize
 setup_fc
Date: Fri, 8 Jul 2016 17:00:38 +0000
Message-ID: <87618083B2453E4A8714035B62D679925066EC02@FMSMSX105.amr.corp.intel.com>
References: <CAE2NFgXe4uPT1WDVzSq_rr54XA7xDNuedoBgHdtd2_WekNQZ+A@mail.gmail.com>
 <038AE347-E85C-4738-BC91-C8C16AE88620@intel.com>
 <87618083B2453E4A8714035B62D679925066EACF@FMSMSX105.amr.corp.intel.com>
 <CAD=hENdLDK6Odi=oV2CNsoKR2_z4tM3oSSgtaA0yiyofErwrog@mail.gmail.com>
 <CAE2NFgVpZoBrNTFV8J3uybuowDj=84nTwgRkta9B0OqGRg-ZDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Rustad, Mark D" <mark.d.rustad@intel.com>,
	netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Patrick McLean <patrickm@gaikai.com>, zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:18761 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755501AbcGHRB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2016 13:01:26 -0400
In-Reply-To: <CAE2NFgVpZoBrNTFV8J3uybuowDj=84nTwgRkta9B0OqGRg-ZDQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogUGF0cmljayBNY0xlYW4gW21haWx0
bzpwYXRyaWNrbUBnYWlrYWkuY29tXQ0KPlNlbnQ6IEZyaWRheSwgSnVseSAwOCwgMjAxNiA5OjQ1
IEFNDQo+VG86IHpodXlqIDx6eWp6eWoyMDAwQGdtYWlsLmNvbT4NCj5DYzogVGFudGlsb3YsIEVt
aWwgUyA8ZW1pbC5zLnRhbnRpbG92QGludGVsLmNvbT47IFJ1c3RhZCwgTWFyayBEDQo+PG1hcmsu
ZC5ydXN0YWRAaW50ZWwuY29tPjsgbmV0ZGV2IDxuZXRkZXZAdmdlci5rZXJuZWwub3JnPjsgaW50
ZWwtd2lyZWQtbGFuDQo+PGludGVsLXdpcmVkLWxhbkBsaXN0cy5vc3Vvc2wub3JnPg0KPlN1Ympl
Y3Q6IFJlOiBbSW50ZWwtd2lyZWQtbGFuXSBbUEFUQ0hdIChyZXNlbmQpIGl4Z2JlOiBhbHdheXMg
aW5pdGlhbGl6ZQ0KPnNldHVwX2ZjDQo+DQo+SG93IGFib3V0IGp1c3QgaW5pdGlhbGl6aW5nIGl0
IHdoZW4gdGhlIHJlc3Qgb2YgdGhlIHN0cnVjdCBpcw0KPmluaXRpYWxpemVkPyBUaGlzIGlzIHdo
YXQgaXMgZG9uZSBmb3IgZXZlcnkgb3RoZXIgbW9kZWwuDQoNClRoYXQgd29ya3MgYXMgd2VsbC4N
Cg0KVGhhbmtzLA0KRW1pbA0KDQo=
