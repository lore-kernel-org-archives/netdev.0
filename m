From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next,v4] hyperv: Add support for virtual Receive
 Side Scaling (vRSS)
Date: Tue, 8 Apr 2014 15:43:25 +0000
Message-ID: <44c82a884313465184d9a15a66248d3b@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1396898623-31667-1-git-send-email-haiyangz@microsoft.com>
	<20140407.144258.2113005286706932770.davem@davemloft.net>
 <CAJzFV36G7Qq1jc1nNkU2h19=c3-N-q9SEOmyMobCRwdirf0+vQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: Sharat Masetty <sharat04@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJzFV36G7Qq1jc1nNkU2h19=c3-N-q9SEOmyMobCRwdirf0+vQ@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogU2hhcmF0IE1hc2V0dHkg
W21haWx0bzpzaGFyYXQwNEBnbWFpbC5jb21dDQo+IFNlbnQ6IE1vbmRheSwgQXByaWwgNywgMjAx
NCA2OjEzIFBNDQo+IFRvOiBEYXZpZCBNaWxsZXINCj4gQ2M6IEhhaXlhbmcgWmhhbmc7IExpbnV4
IE5ldGRldiBMaXN0OyBLWSBTcmluaXZhc2FuOyBvbGFmQGFlcGZsZS5kZTsNCj4gamFzb3dhbmdA
cmVkaGF0LmNvbTsgbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZzsgZHJpdmVyZGV2LQ0KPiBk
ZXZlbEBsaW51eGRyaXZlcnByb2plY3Qub3JnDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggbmV0LW5l
eHQsdjRdIGh5cGVydjogQWRkIHN1cHBvcnQgZm9yIHZpcnR1YWwgUmVjZWl2ZSBTaWRlDQo+IFNj
YWxpbmcgKHZSU1MpDQo+IA0KPiBIaSBaaGFuZywNCj4gDQo+IEhvdyBpcyB0aGlzIGJlbmVmaWNp
YWwgd2hlbiBjb21wYXJlZCB0byBSUFMocmVjZWl2ZSBwYWNrZXQgc3RlZXJpbmcpPw0KPiBDYW4g
eW91IHBsZWFzZSBwcm92aWRlIG1vcmUgZGV0YWlscyBvbiB3aGF0IHRoaXMgcGF0Y2ggZG9lcz8N
Cg0KVGhpcyBwYXRjaCBzdXBwb3J0cyB0aGUgdmlydHVhbCBSU1MgZmVhdHVyZSBwcm92aWRlZCBi
eSBIeXBlci1WIGhvc3RzLiBDdXJyZW50bHksDQp0aGUgaW50ZXJydXB0cyBhcmUgcmVjZWl2ZWQg
b24gb25seSBvbmUgQ1BVIHBlciB2TklDLiBXaXRoIHRoaXMgZmVhdHVyZSwgd2UgY2FuIA0KcmVj
ZWl2ZSBpbnRlcnJ1cHRzIGZyb20gbXVsdGlwbGUgQ1BVcyBhbmQgVk1CdXMgY2hhbm5lbHMgZm9y
IG9uZSB2TklDLiBPdXRnb2luZyANCnBhY2tldHMgYXJlIHB1dCBpbnRvIG11bHRpcGxlIGNoYW5u
ZWxzIGFzIHdlbGwuIFNvIHRoZSBuZXR3b3JrIHRocm91Z2hwdXQgY2FuIA0Kc2NhbGUgdXAgd2l0
aCB0aGUgbnVtYmVyIG9mIENQVXMgZm9yIGEgVk0uDQoNClJQUyBpcyBiYXNpY2FsbHkgYSBzb2Z0
d2FyZSBpbXBsZW1lbnRhdGlvbiBvZiBSU1MuIFRoaXMgaXMgYW4gb25saW5lIGRvYyBhYm91dCAN
CnRoZXNlIGZlYXR1cmVzOg0KaHR0cHM6Ly93d3cua2VybmVsLm9yZy9kb2MvRG9jdW1lbnRhdGlv
bi9uZXR3b3JraW5nL3NjYWxpbmcudHh0DQoNClRoYW5rcywNCi0gSGFpeWFuZw0KDQo=
