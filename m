From: Ozgur Karatas <mueddib@yandex.com>
Subject: Re: Synopsys Ethernet QoS Driver
Date: Tue, 22 Nov 2016 10:38:20 +0200
Message-ID: <1806171479803900@web16j.yandex.ru>
References: <CADvZ6ErjyVR5ShWTk0QesWLYR1m3p8yAMkK8v9gm2kN5xTv8zw@mail.gmail.com>
 <1dbb6047-2bbb-4d56-2a62-ab65a0254844@synopsys.com>
 <20161119135654.GA14079@lnxartpec.se.axis.com>
 <CAJ3bTp7PpUJcz=1JohX=A54UP6vVAafWnB0PGUBSxb5JJiO8Lg@mail.gmail.com>
 <1248f4ce-4859-10e6-fef9-342ea543f8d4@synopsys.com>
 <87c8a24b-0812-7850-cb3f-7be691bab432@st.com>
 <afc18eb0-4c11-9668-498d-982624c6de78@synopsys.com>
 <937252db-9538-2cf6-c8fa-82b558531c51@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "andreas.irestal@axis.com" <andreas.irestal@axis.com>,
 "alexandre.torgue@st.com" <alexandre.torgue@st.com>,
 "saeedm@mellanox.com" <saeedm@mellanox.com>, netdev <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "CARLOS.PALMINHA@synopsys.com" <carlos.palminha@synopsys.com>,
 "idosch@mellanox.com" <idosch@mellanox.com>, mued dib <kreptor@gmail.com>,
 "jiri@mellanox.com" <jiri@mellanox.com>,
 Jeff Kirsher <jeffrey.t.kirsher@intel.com>, David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 "lars.persson@axis.com" <lars.persson@axis.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
 Joao Pinto <joao.pinto@synopsys.com>,
 Rayagond Kokatanur <rayagond@vayavyalabs.com>, Rabin Vincent <rabin@rab.in>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <937252db-9538-2cf6-c8fa-82b558531c51@st.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

SGVsbG8gYWxsLAoKSSB0aGluaywgZXRodG9vbCBhbmQgbWRpbyBkb24ndCB3b3JrIGJlY2F1c2Ug
dGhlIHRvb2wncyBub3Qgc3VwcG9ydCB0byAiUW9TIiwgcmlnaHQ/CgpNYXliZSwgbmVlZCBhIG5l
dyBBUEkuIEknbSBsb29raW5nIGZvciBkd2NlcW9zIGNvZGUgYnV0ICJ0YyIgdG9vbHMgaXMgdmVy
eSBpZGVhLgoKSSBob3BlIHRvIGJlIG1lIGFsd2F5cyBoZWxwZnVsLgoKUmVnYXJkcywKCk96Z3Vy
CgoyMS4xMS4yMDE2LCAxNjozOCwgIkdpdXNlcHBlIENBVkFMTEFSTyIgPHBlcHBlLmNhdmFsbGFy
b0BzdC5jb20+Ogo+IEhlbGxvIEpvYW8KPgo+IE9uIDExLzIxLzIwMTYgMjo0OCBQTSwgSm9hbyBQ
aW50byB3cm90ZToKPj4gwqBTeW5vcHN5cyBRb1MgSVAgaXMgYSBzZXBhcmF0ZWQgaGFyZHdhcmUg
Y29tcG9uZW50LCBzbyBpdCBzaG91bGQgYmUgcmV1c2FibGUgYnkKPj4gwqBhbGwgaW1wbGVtZW50
YXRpb25zIHVzaW5nIGl0IGFuZCBzbyBoYXZlIGl0cyBvd24gImNvcmUgZHJpdmVyIiBhbmQgcGxh
dGZvcm0gKwo+PiDCoHBjaSBnbHVlIGRyaXZlcnMuIFRoaXMgaXMgbmVjZXNzYXJ5IGZvciBleGFt
cGxlIGluIGhhcmR3YXJlIHZhbGlkYXRpb24sIHdoZXJlCj4+IMKgeW91IHByb3RvdHlwZSBhbiBJ
UCBhbmQgaW5zdGFudGlhdGUgaXRzIGRyaXZlcnMgYW5kIHRlc3QgaXQuCj4+Cj4+IMKgV2FzIHRo
ZXJlIGEgc3Ryb25nIHJlYXNvbiB0byBpbnRlZ3JhdGUgUW9TIGZlYXR1cmVzIGRpcmVjdGx5IGlu
IHN0bW1hYyBhbmQgbm90Cj4+IMKgaW4gc3lub3BzeXMvZHdjX2V0aF9xb3MuKj8KPgo+IFdlIGRl
Y2lkZWQgdG8gZW5oYW5jZSB0aGUgc3RtbWFjIG9uIHN1cHBvcnRpbmcgdGhlIFFvUyBmb3Igc2V2
ZXJhbAo+IHJlYXNvbnM7IGZvciBleGFtcGxlIHRoZSBjb21tb24gQVBJcyB0aGF0IHRoZSBkcml2
ZXIgYWxyZWFkeSBleHBvc2VkIGFuZAo+IGFjdHVhbGx5IHN1aXRhYmxlIGZvciBvdGhlciBTWU5Q
IGNoaXBzLiBUaGVuLCBQVFAsIEVFRSwKPiBTL1JHTUlJLCBNTUMgY291bGQgYmUgc2hhcmVkIGFt
b25nIGRpZmZlcmVudCBjaGlwcyB3aXRoIGEgbWluaW1hbAo+IGVmZm9ydC4gVGhpcyBtZWFudCBh
IGxvdCBvZiBjb2RlIGFscmVhZHkgcmVhZHkuCj4KPiBGb3Igc3VyZSwgdGhlIG5ldC1jb3JlLCBF
dGh0b29sLCBtZGlvIHBhcnRzIHdlcmUgcmV1c2VkLiBTYW1lIGZvciB0aGUKPiBnbHVlIGxvZ2lj
IGZpbGVzLgo+IEZvciB0aGUgbGF0dGVyLCB0aGlzIGhlbHBlZCB0byBlYXNpbHkgYnJpbmctdXAg
bmV3IHBsYXRmb3JtcyBhbHNvCj4gYmVjYXVzZSB0aGUgc3RtbWFjIHVzZXMgdGhlIEhXIGNhcCBy
ZWdpc3RlciB0byBhdXRvLWNvbmZpZ3VyZSBtYW55Cj4gcGFydHMgb2YgdGhlIE1BQyBjb3JlLCBE
TUEgYW5kIG1vZHVsZXMuIFRoaXMgaGVscGVkIG1hbnkgdXNlcnMsIEFGQUlLLgo+Cj4gRm9yIHZh
bGlkYXRpb24gcHVycG9zZSwgdGhpcyBpcyBteSBleHBlcmllbmNlLCB0aGUgc3RtbWFjIGhlbHBl
ZAo+IGEgbG90IGJlY2F1c2UgcGVvcGxlIHVzZWQgdGhlIHNhbWUgY29kZSB0byB2YWxpZGF0ZSBk
aWZmZXJlbnQgSFcKPiBhbmQgaXQgd2FzIGVhc3kgdG8gc3dpdGNoIHRvIGEgcGxhdGZvcm0gdG8g
YW5vdGhlciBvbmUgaW4gb3JkZXIgdG8KPiB2ZXJpZnkgLyBjaGVjayBpZiB0aGUgc3VwcG9ydCB3
YXMgb2sgb3IgaWYgYSByZWdyZXNzaW9uIHdhcyBpbnRyb2R1Y2VkLgo+IFRoaXMgaXMgaW1wb3J0
YW50IGZvciBjb21wbGV4IHN1cHBvcnRzIGxpa2UgUFRQIG9yIEVFRS4KPgo+IEhvcGluZyB0aGlz
IGNhbiBoZWxwLgo+Cj4gRG8gbm90IGhlc2l0YXRlIHRvIGNvbnRhY3QgbWUgZm9yIGZ1cnRoZXIg
ZGV0YWlscwo+Cj4gcGVwcGUKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fCmxpbnV4LWFybS1rZXJuZWwgbWFpbGluZyBsaXN0CmxpbnV4LWFybS1rZXJuZWxA
bGlzdHMuaW5mcmFkZWFkLm9yZwpodHRwOi8vbGlzdHMuaW5mcmFkZWFkLm9yZy9tYWlsbWFuL2xp
c3RpbmZvL2xpbnV4LWFybS1rZXJuZWwK
