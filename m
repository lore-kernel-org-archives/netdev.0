From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] x86: bpf_jit: fix compilation of large bpf programs
Date: Tue, 26 May 2015 15:47:19 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB3ED4D@AcuExch.aculab.com>
References: <1432334575-16959-1-git-send-email-ast@plumgrid.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB3EA6A@AcuExch.aculab.com>
	 <1432650922.4060.236.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB3ECB8@AcuExch.aculab.com>
 <1432654198.4060.248.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: 'Alexei Starovoitov' <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:60006 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371AbbEZPtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 11:49:05 -0400
In-Reply-To: <1432654198.4060.248.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IA0KPiBTZW50OiAyNiBNYXkgMjAxNSAxNjozMA0KPiANCj4gPiBZ
ZXMsIGludGVyZXN0aW5nLCBhIGJlbmNobWFyayB0aGF0IG1hbmFnZXMgdG8gcnVuIGEgbG90IG9m
IGNvZGUgJ2NvbGQgY2FjaGUnLg0KPiANCj4gV2UgaGF2ZSBiaW5hcmllcyBoZXJlIGF0IEdvb2ds
ZSB3aXRoIDQwMCBvciA1MDAgTUJ5dGVzIG9mIHRleHQuDQo+IA0KPiBOb3QgYmVuY2htYXJrLCBz
dXBlciByZWFsIHdvcmtsb2FkcyB5b3Uga25vdy4NCg0KSW5kZWVkLCBhbmQgYSBsb3Qgb2YgdGhl
IGNvZGUgaXMgbGlrZWx5IHRvIGJlIHJ1bm5pbmcgJ2NvbGQgY2FjaGUnLg0KDQpJIHdhcyBhbGx1
ZGluZyB0byB0aGUgcHJvYmxlbSB3aGVyZSBwZW9wbGUgd2lsbCBiZW5jaG1hcmsgYSBzbWFsbCBm
dW5jdGlvbg0KYnkgcnVubmluZyBpbiAxMDAwcyBvZiB0aW1lcyBpbiBhIHRpZ2h0IGxvb3Agd2l0
aCBleGFjdGx5IHRoZSBzYW1lIGRhdGEuDQpOb3Qgb25seSBpcyBpdCAnaG90IGNhY2hlJyBidXQg
YW55IGR5bmFtaWMgYnJhbmNoIHByZWRpY3Rpb24gaXMgJ3RyYWluZWQnDQp0byB0aGUgc3BlY2lm
aWMgZGF0YS4NCg0KCURhdmlkDQoNCg0KIA0KDQo=
