From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 10/14] ethtool: Expand documentation of struct
 ethtool_stats
Date: Thu, 13 Feb 2014 09:17:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6BE9D4@AcuExch.aculab.com>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
 <1392243283.15615.14.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Ben Hutchings' <ben@decadent.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60951 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754079AbaBMJSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 04:18:17 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 25204-09 for <netdev@vger.kernel.org>;
 Thu, 13 Feb 2014 09:18:14 +0000 (GMT)
In-Reply-To: <1392243283.15615.14.camel@deadeye.wl.decadent.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogT2YgQmVuIEh1dGNoaW5ncw0KPiAtLyogZm9yIGR1bXBpbmcgTklDLXNwZWNpZmljIHN0
YXRpc3RpY3MgKi8NCj4gKy8qKg0KPiArICogc3RydWN0IGV0aHRvb2xfc3RhdHMgLSBkZXZpY2Ut
c3BlY2lmaWMgc3RhdGlzdGljcw0KPiArICogQGNtZDogQ29tbWFuZCBudW1iZXIgPSAlRVRIVE9P
TF9HU1RBVFMNCj4gKyAqIEBuX3N0YXRzOiBPbiByZXR1cm4sIHRoZSBudW1iZXIgb2Ygc3RhdGlz
dGljcw0KPiArICogQGRhdGE6IEFycmF5IG9mIHN0YXRpc3RpY3MNCj4gKyAqDQo+ICsgKiBVc2Vy
cyBtdXN0IHVzZSAlRVRIVE9PTF9HU1NFVF9JTkZPIG9yICVFVEhUT09MX0dEUlZJTkZPIHRvIGZp
bmQgdGhlDQo+ICsgKiBudW1iZXIgb2Ygc3RhdGlzdGljcyB0aGF0IHdpbGwgYmUgcmV0dXJuZWQu
ICBUaGV5IG11c3QgYWxsb2NhdGUgYQ0KPiArICogYnVmZmVyIG9mIHRoZSBhcHByb3ByaWF0ZSBz
aXplICg4ICogbnVtYmVyIG9mIHN0YXRpc3RpY3MpDQo+ICsgKiBpbW1lZGlhdGVseSBmb2xsb3dp
bmcgdGhpcyBzdHJ1Y3R1cmUuDQo+ICsgKi8NCj4gIHN0cnVjdCBldGh0b29sX3N0YXRzIHsNCj4g
LQlfX3UzMgljbWQ7CQkvKiBFVEhUT09MX0dTVEFUUyAqLw0KPiAtCV9fdTMyCW5fc3RhdHM7CS8q
IG51bWJlciBvZiB1NjQncyBiZWluZyByZXR1cm5lZCAqLw0KPiArCV9fdTMyCWNtZDsNCj4gKwlf
X3UzMgluX3N0YXRzOw0KPiAgCV9fdTY0CWRhdGFbMF07DQo+ICB9Ow0KDQpIbW1tLi4uIEFsdGhv
dWdoIHRoYXQgYWxsb3dzIHNvbWUgc2NyaXB0IHRvIGdlbmVyYXRlIGRvY3VtZW50YXRpb24sDQpm
b3IgYW55b25lIGxvb2tpbmcgYXQgdGhlIGhlZWRlciBmaWxlIGl0IHNlZW1zIGEgcmV0cm9ncmFk
ZSBzdGVwLg0KDQoJRGF2aWQNCg0K
