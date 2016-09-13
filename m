From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC V3 PATCH 03/26] net/netpolicy: get device queue irq
 information
Date: Tue, 13 Sep 2016 12:23:10 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F07750BBF530@SHSMSX103.ccr.corp.intel.com>
References: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
 <1473692159-4017-4-git-send-email-kan.liang@intel.com>
 <665fd0a7-fe83-742a-28fd-d597b28505b5@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "mingo@redhat.com" <mingo@redhat.com>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "kaber@trash.net" <kaber@trash.net>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "keescook@chromium.org" <keescook@chromium.org>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "gorcunov@openvz.org" <gorcunov@openvz.org>,
        "john.stultz@linaro.org" <john.stultz@linaro.org>,
        "aduyck@mirantis.com" <aduyck@mirantis.com>,
        "decot@googlers.com" <decot@googlers.com>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "tom@
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <665fd0a7-fe83-742a-28fd-d597b28505b5@cogentembedded.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiANCj4gSGVsbG8uDQo+IA0KPiBPbiAwOS8xMi8yMDE2IDA1OjU1IFBNLCBrYW4ubGlhbmdAaW50
ZWwuY29tIHdyb3RlOg0KPiANCj4gPiBGcm9tOiBLYW4gTGlhbmcgPGthbi5saWFuZ0BpbnRlbC5j
b20+DQo+ID4NCj4gPiBOZXQgcG9saWN5IG5lZWRzIHRvIGtub3cgZGV2aWNlIGluZm9ybWF0aW9u
LiBDdXJyZW50bHksIGl0J3MgZW5vdWdoIHRvDQo+ID4gb25seSBnZXQgaXJxIGluZm9ybWF0aW9u
IG9mIHJ4IGFuZCB0eCBxdWV1ZXMuDQo+ID4NCj4gPiBUaGlzIHBhdGNoIGludHJvZHVjZXMgbmRv
IG9wcyB0byBkbyBzbywgbm90IGV0aHRvb2wgb3BzLg0KPiA+IEJlY2F1c2UgdGhlcmUgYXJlIGFs
cmVhZHkgc2V2ZXJhbCB3YXlzIHRvIGdldCBpcnEgaW5mb3JtYXRpb24gaW4NCj4gPiB1c2Vyc3Bh
Y2UuIEl0J3Mgbm90IG5lY2Vzc29yeSB0byBleHRlbmQgdGhlIGV0aHRvb2wuDQo+IA0KPiAgICAg
TmVjZXNzYXJ5Lg0KDQpPSy4gSSB3aWxsIGV4dGVuZCB0aGUgZXRodG9vbCBpbiBuZXh0IHZlcnNp
b24uDQoNClRoYW5rcywNCkthbg0KDQo+IA0KPiA+IFNpZ25lZC1vZmYtYnk6IEthbiBMaWFuZyA8
a2FuLmxpYW5nQGludGVsLmNvbT4NCj4gDQo+IFsuLi5dDQo+IA0KPiBNQlIsIFNlcmdlaQ0KDQo=
