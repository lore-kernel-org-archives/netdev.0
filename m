From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 2/2] vhost-net: revert vhost_exceeds_maxpend logic to its
	original
Date: Mon, 21 Aug 2017 20:40:39 +0800
Message-ID: <047bb207-cec6-ece5-470f-340d7c5ee7b7@redhat.com>
References: <20170819064129.27272-1-den@klaipeden.com>
	<0cbc33d6-eb1e-cea4-4cdf-a8a88932da62@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Koichiro Den <den@klaipeden.com>, mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <0cbc33d6-eb1e-cea4-4cdf-a8a88932da62@redhat.com>
Content-Language: en-US
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

CgpPbiAyMDE35bm0MDjmnIgyMeaXpSAxMTowNiwgSmFzb24gV2FuZyB3cm90ZToKPgo+Cj4gT24g
MjAxN+W5tDA45pyIMTnml6UgMTQ6NDEsIEtvaWNoaXJvIERlbiB3cm90ZToKPj4gVG8gZGVwZW5k
IG9uIHZxLm51bSBhbmQgdGhlIHVzYWdlIG9mIFZIT1NUX01BWF9QRU5EIGlzIG5vdCBzdWNjaW5j
dAo+PiBhbmQgaW4gc29tZSBjYXNlIHVuZXhwZWN0ZWQsIHNvIHJldmVydCBpdHMgbG9naWMgcGFy
dCBvbmx5Lgo+Cj4gSGk6Cj4KPiBDb3VsZCB5b3UgZXhwbGFpbiBhIGxpdHRsZSBiaXQgbW9yZSBv
biB0aGUgY2FzZSB0aGF0IGlzIHdhcyBub3QgCj4gc3VmZmljZW50Pwo+Cj4gVGhhbmtzCgpKdXN0
IGhhdmUgYW5vdGhlciB0aG91Z2h0LgoKSSB3b25kZXIgd2hldGhlciBvciBub3QganVzdCB1c2Ug
dWxpbWl0KG1lbWxvY2spIGlzIGJldHRlciBoZXJlLiBJdCAKbG9va3MgbW9yZSBmbGV4aWJsZS4K
ClRoYW5rcwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpW
aXJ0dWFsaXphdGlvbiBtYWlsaW5nIGxpc3QKVmlydHVhbGl6YXRpb25AbGlzdHMubGludXgtZm91
bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlz
dGluZm8vdmlydHVhbGl6YXRpb24=
