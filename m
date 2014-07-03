From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC net-next 08/14] bpf: add eBPF verifier
Date: Thu, 3 Jul 2014 09:13:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726BF1A@AcuExch.aculab.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-9-git-send-email-ast@plumgrid.com>
	<CA+ZOOTODDPN=6SECq1uPPD7AGP1zgBJ+bfYaX9o3YhnaCTiHYQ@mail.gmail.com>
 <CAMEtUuxfrAUDDQVGNsNV2PeDii-6LAwQCbB2XGEHTJDwkkvyWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
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
	Chema Gonzalez <chema@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuxfrAUDDQVGNsNV2PeDii-6LAwQCbB2XGEHTJDwkkvyWg@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogQWxleGVpIFN0YXJvdm9pdG92DQo+ID4+ICsjZGVmaW5lIF8oT1ApICh7IGludCByZXQg
PSBPUDsgaWYgKHJldCA8IDApIHJldHVybiByZXQ7IH0pDQo+ID4gKzEgdG8gcmVtb3ZpbmcgdGhl
IF8gbWFjcm8uIElmIHlvdSB3YW50IHRvIGF2b2lkIHRoZSAzIGxpbmVzIChpcyB0aGVyZQ0KPiA+
IGFueXRoaW5nIGluIHRoZSBzdHlsZSBndWlkZSBhZ2FpbnN0ICJpZiAoKGVycj1PUCkgPCAwKSAu
Li4iID8pLCBhdA0KPiANCj4gYXNzaWdubWVudCBhbmQgZnVuY3Rpb24gY2FsbCBpbnNpZGUgJ2lm
JyA/IEkgZG9uJ3QgbGlrZSBzdWNoIHN0eWxlLg0KPiANCj4gPiBsZWFzdCB1c2Ugc29tZSBtZWFu
aW5nZnVsIG1hY3JvIG5hbWUgKERPX0FORF9DSEVDSywgb3Igc29tZXRoaW5nIGxpa2UNCj4gPiB0
aGF0KS4NCg0KSXQgd291bGQgaGF2ZSB0byBiZSBSRVRVUk5fSUZfTkVHQVRJVkUoKS4NCkJ1dCBl
dmVuIHRoZW4gaXQgaXMgc2tpcHBlZCBieSBzZWFyY2hlcyBmb3IgJ3JldHVybicuDQoNCj4gVHJ5
IHJlcGxhY2luZyBfIHdpdGggYW55IG90aGVyIG5hbWUgYW5kIHNlZSBob3cgYmFkIGl0IHdpbGwg
bG9vay4NCj4gSSB0cmllZCB3aXRoIE1BQ1JPX05BTUUgYW5kIHdpdGggJ2lmIChlcnIpIGdvdG8n
IGFuZCB3aXRoICdpZiAoZXJyKSByZXR1cm4nLA0KPiBiZWZvcmUgSSBjb252ZXJnZWQgb24gXyBt
YWNyby4NCj4gSSB0aGluayBpdCdzIGEgaGlkZGVuIGdlbSBvZiB0aGlzIHBhdGNoLg0KDQpObywg
aXQgaXMgb25lIG9mIHRob3NlIHRoaW5ncyB0aGF0ICdzZWVtcyBsaWtlIGEgZ29vZCBpZGVhIGF0
IHRoZSB0aW1lJywNCmJ1dCBjYXVzZXMgZ3JpZWYgbXVjaCBsYXRlciBvbi4NCg0KSGF2ZSB5b3Ug
Y29uc2lkZXJlZCBzYXZpbmcgdGhlIGVycm9yIGNvZGUgaW50byAnZW52JyBhbmQgbWFraW5nIG1v
c3Qgb2YNCnRoZSBmdW5jdGlvbnMgcmV0dXJuIGlmIGFuIGVycm9yIGlzIHNldD8NClRoZW4gdGhl
IGNhbGxpbmcgY29kZSBuZWVkIG5vdCBjaGVjayB0aGUgcmVzdWx0IG9mIGV2ZXJ5IGZ1bmN0aW9u
IGNhbGwuDQoNCglEYXZpZA0KDQo=
