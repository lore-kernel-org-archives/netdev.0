From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC net-next 08/14] bpf: add eBPF verifier
Date: Wed, 2 Jul 2014 08:11:20 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726B207@AcuExch.aculab.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-9-git-send-email-ast@plumgrid.com>
	<53B26BB0.90209@redhat.com>
 <CAMEtUuyc3+jrxG4r4=fk=Gc9OMhO8a2X1oyWPx1LsKzewVf01w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"Arnaldo Carvalho de Melo" <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	"Linux API" <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: 'Alexei Starovoitov' <ast@plumgrid.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuyc3+jrxG4r4=fk=Gc9OMhO8a2X1oyWPx1LsKzewVf01w@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogQWxleGVpIFN0YXJvdm9pdG92DQouLi4NCj4gPj4gKyNkZWZpbmUgXyhPUCkgKHsgaW50
IHJldCA9IE9QOyBpZiAocmV0IDwgMCkgcmV0dXJuIHJldDsgfSkNCi4uLg0KPiA+PiArICAgICAg
IF8oZ2V0X21hcF9pbmZvKGVudiwgbWFwX2lkLCAmbWFwKSk7DQo+ID4NCj4gPiBOaXQ6IHN1Y2gg
bWFjcm9zIHNob3VsZCBiZSByZW1vdmVkLCBwbGVhc2UuDQo+IA0KPiBJdCBtYXkgc3VyZWx5IGxv
b2sgdW5jb252ZW50aW9uYWwsIGJ1dCBhbHRlcm5hdGl2ZSBpcyB0byByZXBsYWNlDQo+IGV2ZXJ5
IHVzYWdlIG9mIF8gbWFjcm8gd2l0aDoNCj4gZXJyID0NCj4gaWYgKGVycikNCj4gICByZXR1cm4g
ZXJyOw0KPiANCj4gYW5kIHNpbmNlIHRoaXMgbWFjcm8gaXMgdXNlZCAzOCB0aW1lcywgaXQgd2ls
bCBhZGQgfjEyMCB1bm5lY2Vzc2FyeQ0KPiBsaW5lcyB0aGF0IHdpbGwgb25seSBtYWtlIGNvZGUg
bXVjaCBoYXJkZXIgdG8gZm9sbG93Lg0KPiBJIHRyaWVkIG5vdCB1c2luZyBtYWNybyBhbmQgcmVz
dWx0cyB3ZXJlIG5vdCBwbGVhc2luZy4NCg0KVGhlIHByb2JsZW0gaXMgdGhhdCB0aGV5IGFyZSBo
aWRkZW4gY29udHJvbCBmbG93Lg0KQXMgc3VjaCB0aGV5IG1ha2UgZmxvdyBhbmFseXNpcyBoYXJk
ZXIgZm9yIHRoZSBjYXN1YWwgcmVhZGVyLg0KDQpUaGUgZXh0cmEgbGluZXMgcmVhbGx5IHNob3Vs
ZG4ndCBtYXR0ZXIuDQoNCglEYXZpZA0KDQo=
