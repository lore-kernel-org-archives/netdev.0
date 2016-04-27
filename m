From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH V2 2/5] samples/bpf: Makefile verify LLVM
 compiler avail and bpf target is supported
Date: Wed, 27 Apr 2016 13:52:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4AB86F@AcuExch.aculab.com>
References: <20160426162650.22962.20516.stgit@firesoul>
 <20160426162716.22962.36473.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>,
	"bblanco@plumgrid.com" <bblanco@plumgrid.com>,
	"naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>,
	"borkmann@iogearbox.net" <borkmann@iogearbox.net>,
	"alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>
To: 'Jesper Dangaard Brouer' <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:57405 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbcD0Ny3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 09:54:29 -0400
In-Reply-To: <20160426162716.22962.36473.stgit@firesoul>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSmVzcGVyIERhbmdhYXJkIEJyb3Vlcg0KPiBTZW50OiAyNiBBcHJpbCAyMDE2IDE3OjI3
DQo+IE1ha2UgY29tcGlsaW5nIHNhbXBsZXMvYnBmIG1vcmUgdXNlciBmcmllbmRseSwgYnkgZGV0
ZWN0aW5nIGlmIExMVk0NCj4gY29tcGlsZXIgdG9vbCAnbGxjJyBpcyBhdmFpbGFibGUsIGFuZCBh
bHNvIGRldGVjdCBpZiB0aGUgJ2JwZicgdGFyZ2V0DQo+IGlzIGF2YWlsYWJsZSBpbiB0aGlzIHZl
cnNpb24gb2YgTExWTS4NCi4uLg0KPiBkaWZmIC0tZ2l0IGEvc2FtcGxlcy9icGYvTWFrZWZpbGUg
Yi9zYW1wbGVzL2JwZi9NYWtlZmlsZQ0KPiBpbmRleCA1YmFlOTUzNmYxMDAuLjQ1ODU5Yzk5ZjU3
MyAxMDA2NDQNCj4gLS0tIGEvc2FtcGxlcy9icGYvTWFrZWZpbGUNCj4gKysrIGIvc2FtcGxlcy9i
cGYvTWFrZWZpbGUNCj4gQEAgLTg1LDYgKzg1LDI0IEBAIEhPU1RMT0FETElCRVNfdGVzdF9vdmVy
aGVhZCArPSAtbGVsZiAtbHJ0DQo+ICAjICBtYWtlIHNhbXBsZXMvYnBmLyBMTEM9fi9naXQvbGx2
bS9idWlsZC9iaW4vbGxjDQo+ICBMTEMgPz0gbGxjDQo+IA0KPiArIyBWZXJpZnkgTExWTSBjb21w
aWxlciBpcyBhdmFpbGFibGUgYW5kIGJwZiB0YXJnZXQgaXMgc3VwcG9ydGVkDQo+ICsuUEhPTlk6
IHZlcmlmeV9jbWRfbGxjIHZlcmlmeV90YXJnZXRfYnBmDQo+ICsNCj4gK3ZlcmlmeV9jbWRfbGxj
Og0KPiArCUBpZiAhICh3aGljaCAiJHtMTEN9IiA+IC9kZXYvbnVsbCAyPiYxKTsgdGhlbiBcDQoN
CllvdSBzaG91bGQgdXNlICd0eXBlJyBub3QgJ3doaWNoJy4NCid0eXBlJyBpcyBhIHBvc2l4IHNo
ZWxsIGJ1aWx0aW4sICd3aGljaCcgaXMgYSBzY3JpcHQvcHJvZ3JhbQ0KdGhhdCB0cmllcyB0byBl
bXVsYXRlIGEgJ2NzaCcgYnVpbHRpbi4NCllvdSB3YW50IHRvIGtub3cgd2hldGhlciB0aGUgc2hl
bGwgdGhhdCBtYWtlIHJ1bnMgY2FuIGV4ZWN1dGUgJHtMTEN9DQpub3Qgd2hldGhlciBhIGNzaCB3
b3VsZCBiZSBhYmxlIHRvIHJ1biBpdC4NCg0KWW91IG1pZ2h0IGFsc28gd2FudCB0byB3b3JyeSBh
Ym91dDoNCiAgICBMTEM9Ii9wYXRoX3RvX2xsYy9sbGMgLWV4dHJhX2FyZyIgbWFrZSBmdWJhcg0K
DQoJRGF2aWQNCg0K
