From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 3/3] ipv6: fix checkpatch errors of "foo*"
 and "foo * bar"
Date: Fri, 28 Mar 2014 10:54:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6EB756@AcuExch.aculab.com>
References: <1395979624-8544-1-git-send-email-wangyufen@huawei.com>
 <1395979624-8544-4-git-send-email-wangyufen@huawei.com>
 <1395980521.19009.8.camel@joe-AO722>
 <20140328.014012.963819707045886028.davem@davemloft.net>
 <20140328101704.GD11063@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "joe@perches.com" <joe@perches.com>,
	"wangyufen@huawei.com" <wangyufen@huawei.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Hannes Frederic Sowa' <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53761 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751164AbaC1KzE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 06:55:04 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26388-05 for <netdev@vger.kernel.org>;
 Fri, 28 Mar 2014 10:55:02 +0000 (GMT)
In-Reply-To: <20140328101704.GD11063@order.stressinduktion.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSGFubmVzIEZyZWRlcmljIFNvd2ENCj4gPiA+IFBlcmhhcHMgYWxsIHRoZSBfX2lubGlu
ZV9fIHVzZXMgY291bGQgYmUgY2hhbmdlZCB0byBpbmxpbmUgdG9vLg0KPiA+DQo+ID4gT3IgcmF0
aGVyLCBkZWxldGVkIGNvbXBsZXRlbHksIHRoaXMgaXMgYSAqLmMgZmlsZSBhZnRlciBhbGwuDQoN
ClBlcnNvbmFsbHkgSSB3b3VsZG4ndCBkbyBhIGJsYW5rZXQgcmVtb3ZhbCBvZiAnaW5saW5lJyBm
cm9tIC5jIGZpbGVzLg0KQnV0IEkgd2lsbCBhZ3JlZSB0aGF0IHNvbWUgbGFyZ2UgZnVuY3Rpb25z
IGhhdmUgYmVlbiBpbmFwcHJvcHJpYXRlbHkNCm1hcmtlZCAnaW5saW5lJy4NClRoZSBjb21wbGll
ciBkb2Vzbid0IGFsd2F5cyBtYWtlIHRoZSByaWdodCBndWVzcy4NCg0KPiBTbWFydC1hcnNpbmc6
DQo+IA0KPiBSZW1vdmluZyBpbmxpbmUga2V5d29yZCBtYWtlcyB0aGUgZnVuY3Rpb24gdmlzaWJs
ZSB0byB0cmFjaW5nIGlmDQo+IGl0IGRpZG4ndCBnZXQgaW5saW5lZC4gSSB0aGluayB0aGlzIGlz
IGEgbmljZSBzaWRlLWVmZmVjdCBiZWNhdXNlIGRlYnVnDQo+IGtlcm5lbHMgYXJlIG9mdGVuIGNv
bXBpbGVkIHdpdGggbGVzcyBhZ2dyZXNzaXZlIGlubGluaW5nIG9wdGlvbnMNCj4gKHJlYWRhYmxl
IGFzbSBrY29uZmlnIG9wdGlvbikuDQoNCkkgd2FudCB0byBkZWJ1ZyB0aGUgc2FtZSBiaW5hcnkg
dGhhdCB3aWxsIHJ1biBpbiBwcm9kdWN0aW9uLg0KRG9kZ3kgY29kZSBjYW4gYmUgYWZmZWN0ZWQg
YnkgYWxsIHNvcnRzIG9mIGNvbXBpbGVyIG9wdGlvbnMuDQoNClRoZSBiZXN0IG9uZSB3YXMgYSBw
cm9ibGVtIHdpdGggdGhlIHNoZWxsIGRlbGV0aW5nIHRoZSBsYXN0DQpjaGFyYWN0ZXIgb2YgYSAk
KC4uLikgc3Vic3RpdHV0aW9uLg0KVGhlIGNvZGUgcmFuIG9mZiB0aGUgYmVnaW5uaW5nIG9mIGFu
IG9uLXN0YWNrIGJ1ZmZlciB3aGVuIHRyaW1taW5nDQp0cmFpbGluZyAnXG4nIGFuZCAnZm91bmQn
IGEgJ1xuJyBieXRlIGx1cmtpbmcgaW4gdGhlIHVud3JpdHRlbg0Kc3RhY2sgKHRoaXMgd2FzIHdl
bGwgZG93biB0aGUgc3RhY2ssIGFuZCBoYWQgYmVlbiB3cml0dGVuIG11Y2gsDQptdWNoIGVhcmxp
ZXIpLg0KVGhlIGVycm9yIHdhcyBvbmx5IGV2ZXIgbGlrZWx5IG9uIGJpZy1lbmRpYW4gc3lzdGVt
cyAodGhlIG1zYiBvZg0KYSB3b3JkIGlzIGxlc3MgbGlrZWx5IHRvIGJlICdcbicuDQoNCglEYXZp
ZA0KDQo=
