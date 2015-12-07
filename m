From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: bpf: undefined shift in __bpf_prog_run
Date: Mon, 7 Dec 2015 11:14:22 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBE6492@AcuExch.aculab.com>
References: <20151204184333.GA42737@ast-mbp.thefacebook.com>
 <CACT4Y+YLV4scGXSFz=G3ACa-WE8VuT5wDGvPBV9D2Q+devxedA@mail.gmail.com>
 <20151204191013.GB45508@ast-mbp.thefacebook.com>
 <20151204.142651.968075964630586979.davem@davemloft.net>
 <CACT4Y+Y6vzvHuxk=o5Y_f2qDCGW30cAOCuyCeoLtj28Xh3G1dA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Alexei Starovoitov <ast@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Andrey Ryabinin <ryabinin.a.a@gmail.com>
To: 'Dmitry Vyukov' <dvyukov@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+Y6vzvHuxk=o5Y_f2qDCGW30cAOCuyCeoLtj28Xh3G1dA@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogRG1pdHJ5IFZ5dWtvdg0KPiBTZW50OiAwNCBEZWNlbWJlciAyMDE1IDE5OjQ5DQouLi4N
Cj4gMy40LjMNCj4gdW5kZWZpbmVkIGJlaGF2aW9yDQo+IDEgYmVoYXZpb3IsIHVwb24gdXNlIG9m
IGEgbm9ucG9ydGFibGUgb3IgZXJyb25lb3VzIHByb2dyYW0gY29uc3RydWN0DQo+IG9yIG9mIGVy
cm9uZW91cyBkYXRhLCBmb3Igd2hpY2ggdGhpcyBJbnRlcm5hdGlvbmFsIFN0YW5kYXJkIGltcG9z
ZXMgbm8NCj4gcmVxdWlyZW1lbnRzDQo+IDIgTk9URSBQb3NzaWJsZSB1bmRlZmluZWQgYmVoYXZp
b3IgcmFuZ2VzIGZyb20gaWdub3JpbmcgdGhlIHNpdHVhdGlvbg0KPiBjb21wbGV0ZWx5IHdpdGgg
dW5wcmVkaWN0YWJsZSByZXN1bHRzLCB0byBiZWhhdmluZyBkdXJpbmcgdHJhbnNsYXRpb24NCj4g
b3IgcHJvZ3JhbSBleGVjdXRpb24gaW4gYSBkb2N1bWVudGVkIG1hbm5lciBjaGFyYWN0ZXJpc3Rp
YyBvZiB0aGUNCj4gZW52aXJvbm1lbnQgKHdpdGggb3Igd2l0aG91dCB0aGUgaXNzdWFuY2Ugb2Yg
YSBkaWFnbm9zdGljIG1lc3NhZ2UpLCB0bw0KPiB0ZXJtaW5hdGluZyBhIHRyYW5zbGF0aW9uIG9y
IGV4ZWN1dGlvbg0KDQpXaGlsZSAndW5kZWZpbmVkIGJlaGF2aW91cicgaXMgYWxsb3dlZCB0byBp
bmNsdWRlICdmaXJpbmcgYW4gSUNCTSBhdA0KdGhlIGN1cnJlbnQgbG9jYXRpb24gb2YgdGhlIHBl
cnNvbiB3aG8gd3JvdGUgdGhlIGNvZGUnIGl0IGlzIHZlcnkNCnVubGlrZWx5IHRvIHJlc3VsdCBp
biBhbnl0aGluZyBvdGhlciB0aGFuIGFuIHVuZXhwZWN0ZWQgdmFsdWUNCmFuZCB0aGUgY29tcGls
ZXIgbWFraW5nIGZhbHNlIGFzc3VtcHRpb25zIGFib3V0IHRoZSB2YWx1ZS4NCg0KZWcgdGhlIGNv
bXBpbGVyIGNhbiBhc3N1bWUgdGhpcyBpcyBhbiBpbmZpbml0ZSBsb29wOg0KCWludCBpOw0KCWZv
ciAoaSA9IDA7IGkgPj0gMDsgaSsrKQ0KCQkuLi4NCg0KCURhdmlkDQo=
