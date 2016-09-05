From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 3/6] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Mon, 5 Sep 2016 15:30:08 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB00F4930@AcuExch.aculab.com>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
 <1472241532-11682-4-git-send-email-daniel@zonque.org>
 <20160827000819.GB29480@ast-mbp.thefacebook.com>
 <4799c1ce-4cb6-0148-26ce-8b6a8ac2a0eb@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "htejun@fb.com" <htejun@fb.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "ast@fb.com" <ast@fb.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "kafai@fb.com" <kafai@fb.com>, "fw@strlen.de" <fw@strlen.de>,
        "pablo@netfilter.org" <pablo@netfilter.org>,
        "harald@redhat.com" <harald@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "sargun@sargun.me" <sargun@sargun.me>
To: 'Daniel Mack' <daniel@zonque.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.189]:51428 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933977AbcIEPdH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 11:33:07 -0400
In-Reply-To: <4799c1ce-4cb6-0148-26ce-8b6a8ac2a0eb@zonque.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGFuaWVsIE1hY2sNCj4gPj4gKw0KPiA+PiArCXN0cnVjdCB7IC8qIGFub255bW91cyBz
dHJ1Y3QgdXNlZCBieSBCUEZfUFJPR19BVFRBQ0gvREVUQUNIIGNvbW1hbmRzICovDQo+ID4+ICsJ
CV9fdTMyCQl0YXJnZXRfZmQ7CS8qIGNvbnRhaW5lciBvYmplY3QgdG8gYXR0YWNoIHRvICovDQo+
ID4+ICsJCV9fdTMyCQlhdHRhY2hfYnBmX2ZkOwkvKiBlQlBGIHByb2dyYW0gdG8gYXR0YWNoICov
DQo+ID4+ICsJCV9fdTMyCQlhdHRhY2hfdHlwZTsJLyogQlBGX0FUVEFDSF9UWVBFXyogKi8NCj4g
Pj4gKwkJX191NjQJCWF0dGFjaF9mbGFnczsNCj4gPj4gKwl9Ow0KPiA+DQo+ID4gdGhlcmUgaXMg
YSA0IGJ5dGUgaG9sZSBpbiB0aGlzIHN0cnVjdC4gQ2FuIHdlIHBhY2sgaXQgZGlmZmVyZW50bHk/
DQo+IA0KPiBPa2F5IC0gSSBzd2FwcGVkICJ0eXBlIiBhbmQgImZsYWdzIiB0byByZXBhaXIgdGhp
cy4NCg0KVGhhdCBqdXN0IG1vdmVzIHRoZSBwYWQgdG8gdGhlIGVuZCBvZiB0aGUgc3RydWN0dXJl
Lg0KU3RpbGwgbGlrZWx5IHRvIGNhdXNlIGEgcHJvYmxlbSBmb3IgMzJiaXQgYXBwcyBvbiBhIDY0
Yml0IGtlcm5lbC4NCklmIHlvdSBjYW4ndCB0aGluayBvZiBhbnkgZmxhZ3MsIHdoeSA2NCBvZiB0
aGVtPw0KDQoJRGF2aWQNCg0K
