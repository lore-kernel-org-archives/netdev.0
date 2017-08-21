From: Koichiro Den <den@klaipeden.com>
Subject: Re: [PATCH 2/2] vhost-net: revert vhost_exceeds_maxpend logic to
	its original
Date: Mon, 21 Aug 2017 22:32:20 +0900
Message-ID: <1503322340.8694.9.camel@klaipeden.com>
References: <20170819064129.27272-1-den@klaipeden.com>
	<0cbc33d6-eb1e-cea4-4cdf-a8a88932da62@redhat.com>
	<047bb207-cec6-ece5-470f-340d7c5ee7b7@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <047bb207-cec6-ece5-470f-340d7c5ee7b7@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

T24gTW9uLCAyMDE3LTA4LTIxIGF0IDIwOjQwICswODAwLCBKYXNvbiBXYW5nIHdyb3RlOgo+IAo+
IE9uIDIwMTflubQwOOaciDIx5pelIDExOjA2LCBKYXNvbiBXYW5nIHdyb3RlOgo+ID4gCj4gPiAK
PiA+IE9uIDIwMTflubQwOOaciDE55pelIDE0OjQxLCBLb2ljaGlybyBEZW4gd3JvdGU6Cj4gPiA+
IFRvIGRlcGVuZCBvbiB2cS5udW0gYW5kIHRoZSB1c2FnZSBvZiBWSE9TVF9NQVhfUEVORCBpcyBu
b3Qgc3VjY2luY3QKPiA+ID4gYW5kIGluIHNvbWUgY2FzZSB1bmV4cGVjdGVkLCBzbyByZXZlcnQg
aXRzIGxvZ2ljIHBhcnQgb25seS4KPiA+IAo+ID4gSGk6Cj4gPiAKPiA+IENvdWxkIHlvdSBleHBs
YWluIGEgbGl0dGxlIGJpdCBtb3JlIG9uIHRoZSBjYXNlIHRoYXQgaXMgd2FzIG5vdMKgCj4gPiBz
dWZmaWNlbnQ/Cj4gPiAKPiA+IFRoYW5rcwo+IAo+IEp1c3QgaGF2ZSBhbm90aGVyIHRob3VnaHQu
Cj4gCj4gSSB3b25kZXIgd2hldGhlciBvciBub3QganVzdCB1c2UgdWxpbWl0KG1lbWxvY2spIGlz
IGJldHRlciBoZXJlLiBJdMKgCj4gbG9va3MgbW9yZSBmbGV4aWJsZS4KPiAKPiBUaGFua3MKSXQg
c291bmRzIGEgYmV0dGVyIGFwcHJvYWNoLCB0aG91Z2ggYXQgcHJlc2VudCBJIGhhdmUgZ290IG5v
IGlkZWEgaG93IG11Y2gKcG9ydGlvbiBpdCBzaG91bGQgYmUuCgpfX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fXwpWaXJ0dWFsaXphdGlvbiBtYWlsaW5nIGxpc3QK
VmlydHVhbGl6YXRpb25AbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5s
aW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vdmlydHVhbGl6YXRpb24=
