From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next v3 2/5] virtio-net: transmit napi
Date: Tue, 25 Apr 2017 10:32:45 -0400
Message-ID: <CAF=yD-KJ_nFzOmOtmeUYXiO_+xO2yWB8xn_-jEm9zgycYzPOzQ@mail.gmail.com>
References: <20170424174930.82623-1-willemdebruijn.kernel@gmail.com>
	<20170424174930.82623-3-willemdebruijn.kernel@gmail.com>
	<2c5491c0-4473-75d1-fa0f-a0dbd4dc626d@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Network Development <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>, "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <2c5491c0-4473-75d1-fa0f-a0dbd4dc626d@redhat.com>
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

T24gVHVlLCBBcHIgMjUsIDIwMTcgYXQgNDozNiBBTSwgSmFzb24gV2FuZyA8amFzb3dhbmdAcmVk
aGF0LmNvbT4gd3JvdGU6Cj4KPgo+IE9uIDIwMTflubQwNOaciDI15pelIDAxOjQ5LCBXaWxsZW0g
ZGUgQnJ1aWpuIHdyb3RlOgo+Pgo+PiBAQCAtMTM3MSw4ICsxNDE5LDEwIEBAIHN0YXRpYyBpbnQg
dmlydG5ldF9jbG9zZShzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQo+PiAgICAgICAgIC8qIE1ha2Ug
c3VyZSByZWZpbGxfd29yayBkb2Vzbid0IHJlLWVuYWJsZSBuYXBpISAqLwo+PiAgICAgICAgIGNh
bmNlbF9kZWxheWVkX3dvcmtfc3luYygmdmktPnJlZmlsbCk7Cj4+ICAgLSAgICAgZm9yIChpID0g
MDsgaSA8IHZpLT5tYXhfcXVldWVfcGFpcnM7IGkrKykKPj4gKyAgICAgICBmb3IgKGkgPSAwOyBp
IDwgdmktPm1heF9xdWV1ZV9wYWlyczsgaSsrKSB7Cj4+ICAgICAgICAgICAgICAgICBuYXBpX2Rp
c2FibGUoJnZpLT5ycVtpXS5uYXBpKTsKPj4gKyAgICAgICAgICAgICAgIG5hcGlfZGlzYWJsZSgm
dmktPnNxW2ldLm5hcGkpOwo+PiArICAgICAgIH0KPgo+Cj4gTG9va3MgbGlrZSB0aGlzIHdpbGwg
d2FpdCBmb3IgZXZlciBpZiBuYXBpX3R4IGlzIGZhbHNlIGJlY2F1c2Ugd2UgbmV2ZXIKPiBlbmFi
bGUgdGhlIE5BUEkgc28gd2Ugd2lsbCB3YWl0IGZvciBOQVBJX1NUQVRFX1NDSEVEIHRvIGJlIGNs
ZWFyZWQuCgpJbmRlZWQsIHRoYW5rcyEgSSdsbCBzZW5kIGEgZml4LgpfX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpWaXJ0dWFsaXphdGlvbiBtYWlsaW5nIGxp
c3QKVmlydHVhbGl6YXRpb25AbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0
cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vdmlydHVhbGl6YXRpb24=
