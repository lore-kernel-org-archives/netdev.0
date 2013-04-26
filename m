From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH net-next 2/6] x86: bpf_jit_comp: support BPF_S_ANC_SECCOMP_LD_W instruction
Date: Fri, 26 Apr 2013 16:38:09 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7209@saturn3.aculab.com>
References: <1366962706-24204-1-git-send-email-xi.wang@gmail.com> <1366962706-24204-3-git-send-email-xi.wang@gmail.com> <1366985926.8964.190.camel@edumazet-glaptop> <CAKU6vyZfYR-2408G0_Fkp-PS5x5rMH+s4_OOWqqi7Nt+UfiUPg@mail.gmail.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7208@saturn3.aculab.com> <1366990066.8964.216.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Xi Wang" <xi.wang@gmail.com>,
	"Daniel Borkmann" <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Russell King" <linux@arm.linux.org.uk>,
	"Heiko Carstens" <heiko.carstens@de.ibm.com>,
	"Eric Dumazet" <edumazet@google.com>,
	"Will Drewry" <wad@chromium.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1366990066.8964.216.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiA+ID4gPj4gKyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgZnVuYyA9ICh1OCAqKXNlY2Nv
bXBfYnBmX2xvYWQ7DQo+ID4gPiA+PiArICAgICAgICAgICAgICAgICAgICAgICAgICAgICB0X29m
ZnNldCA9IGZ1bmMgLSAoaW1hZ2UgKyBhZGRyc1tpXSk7DQo+ID4gPiA+PiArICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICBFTUlUMV9vZmYzMigweGJmLCBLKTsgLyogbW92IGltbTMyLCVlZGkg
Ki8NCj4gPiA+ID4+ICsgICAgICAgICAgICAgICAgICAgICAgICAgICAgIEVNSVQxX29mZjMyKDB4
ZTgsIHRfb2Zmc2V0KTsgLyogY2FsbCBzZWNjb21wX2JwZl9sb2FkICovDQo+ID4gPiA+PiArICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICBicmVhazsNCj4gPiA+ID4+ICsjZW5kaWYNCj4gPiA+
ID4NCj4gPiA+ID4gVGhpcyBzZWVtcyBzZXJpb3VzbHkgd3JvbmcgdG8gbWUuDQo+ID4gPg0KPiA+
ID4gQ2FuIHlvdSBlbGFib3JhdGU/DQo+ID4NCj4gPiBUaGUgJ2NhbGwgc2VjY29tcF9icGZfbG9h
ZCcgbmVlZHMgYSBwYy1yZWxhdGl2ZSBvZmZzZXQsDQo+ID4gSSBhc3N1bWUgdGhhdCBpcyB3aGF0
IEVNSVQxX29mZjMyKCkgZ2VuZXJhdGVzLg0KPiA+DQo+ID4gVGhlIG90aGVyIHR3byBpbnN0cnVj
dGlvbnMgd2FudCBhbiBhYnNvbHV0ZSAzMiBiaXQgdmFsdWUuLi4NCj4gDQo+IEhtbSwgdGhpcyBw
YXJ0IGlzIGZpbmUsIHdlIHBlcmZvcm0gdGhlIHJlbGF0aXZlIGFkanVzdG1lbnRzIGluDQo+IHRf
b2Zmc2V0ID0gZnVuYyAtIChpbWFnZSArIGFkZHJzW2ldKTsNCg0KVGhlIGNhbGwgbmVlZHMgdGhl
IGRpc3BsYWNlbWVudCBmcm9tIHRoZSBhZGRyZXNzIG9mDQp0aGUgaW5zdHJ1Y3Rpb24gZm9sbG93
aW5nIHRoZSBjYWxsLg0KSSBjYW4ndCBpbWFnaW5lIGFueSB3YXkgaW4gd2hpY2ggYWJvdmUgY2Fu
IGFsbG93IGZvciB0aGUgNSBieXRlDQonbW92IGltbTMyLCVlZGknIGluc3RydWN0aW9uLg0KDQpJ
J2QgaGF2ZSB0aG91Z2h0IHRoZXJlIHdvdWxkIGJlIGFuIEVNSVQxX2ltbTMyKCkuDQooSSd2ZSB3
cml0dGVuIGEgbG90IG9mIHg4NiBhc20gaW4gbXkgZGF5cyEpDQoNCglEYXZpZA0KDQo=
