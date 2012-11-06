From: "Woodhouse, David" <david.woodhouse@intel.com>
Subject: Re: [PATCH v3 5/7] pppoatm: take ATM socket lock in pppoatm_send()
Date: Tue, 6 Nov 2012 22:57:39 +0000
Message-ID: <1352242658.7340.19.camel@shinybook.infradead.org>
References: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
	 <1352240222-363-6-git-send-email-krzysiek@podlesie.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Krzysztof Mazur <krzysiek@podlesie.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352240222-363-6-git-send-email-krzysiek@podlesie.net>
Content-Language: en-US
Content-ID: <1DDACE81D6B5FA409A8BD38C858EA4BA@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gVHVlLCAyMDEyLTExLTA2IGF0IDIzOjE3ICswMTAwLCBLcnp5c3p0b2YgTWF6dXIgd3JvdGU6
DQo+ICsgICAgICAgaWYgKHNvY2tfb3duZWRfYnlfdXNlcihza19hdG0odmNjKSkpDQo+ICsgICAg
ICAgICAgICAgICBnb3RvIG5vc3BhY2U7DQoNCkkgc3RpbGwgdGhpbmsgdGhpcyBvbmUgY2FuIGxl
YWQgdG8gYW4gaW5maW5pdGUgc3RhbGwgb2YgdGhlIFBQUCBjaGFubmVsLA0KYmVjYXVzZSB3ZSBy
ZXR1cm4gMCBmcm9tIHBwcG9hdG1fc2VuZCgpIGJ1dCBuZXZlciBtYWtlIGEgbGF0ZXIgY2FsbCB0
bw0KcHBwX291dHB1dF93YWtldXAoKSB0byB1bmJsb2NrIGl0Lg0KDQpJbiB0aGUgZXhpc3Rpbmcg
Y2FzZXMgd2hlcmUgd2UgY291bGQgcmV0dXJuIDAgKGJlY2F1c2UNCnBwcG9hdG1fbWF5X3NlbmQo
KSBzYWlkIG5vKSwgd2Ugd2VyZSBjYXJlZnVsIHRvIHNldCB0aGUgQkxPQ0tFRCBmbGFnIGFuZA0K
d2UgKmtuZXcqIHRoYXQgYSBwYWNrZXQgd2FzIGluIGZsaWdodCBzbyB3ZSdkIGdldCB0byB3YWtl
IGl0IHVwIGFnYWluIG9uDQphIHN1YnNlcXVlbnQgcHBwb2F0bV9wb3AoKS4NCg0KTm9uZSBvZiB0
aGF0IHdvcmtzIGZvciB0aGlzIG5ldyBjb2RlIHBhdGggdGhhdCByZXR1cm5zIHplcm8uDQoNCi0t
IA0KICAgICAgICAgICAgICAgICAgIFNlbnQgd2l0aCBNZWVHbydzIEFjdGl2ZVN5bmMgc3VwcG9y
dC4NCg0KRGF2aWQgV29vZGhvdXNlICAgICAgICAgICAgICAgICAgICAgICAgICAgIE9wZW4gU291
cmNlIFRlY2hub2xvZ3kgQ2VudHJlDQpEYXZpZC5Xb29kaG91c2VAaW50ZWwuY29tICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgSW50ZWwgQ29ycG9yYXRpb24NCg0KDQoNCg==
