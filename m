From: "Coelho, Luciano" <luciano.coelho@intel.com>
Subject: Re: [PATCH 1/1] iwlwifi: rs: remove superfluous check
Date: Thu, 19 May 2016 08:27:13 +0000
Message-ID: <1463646433.29999.50.camel@intel.com>
References: <1463527868-12226-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linuxwifi <linuxwifi@intel.com>,
	"eyal@wizery.com" <eyal@wizery.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Greenman, Gregory" <gregory.greenman@intel.com>,
	"Bondar, Alexander" <alexander.bondar@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"xypron.glpk@gmx.de" <xypron.glpk@gmx.de>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463527868-12226-1-git-send-email-xypron.glpk@gmx.de>
Content-Language: en-US
Content-ID: <563BCFB089518847B5367C0C20B37A64@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gV2VkLCAyMDE2LTA1LTE4IGF0IDAxOjMxICswMjAwLCBIZWlucmljaCBTY2h1Y2hhcmR0IHdy
b3RlOg0KPiBJZiB3ZSBkZXJlZmVyZW5jZSBhIHZhcmlhYmxlIGFueXdheSBpbiBvdGhlciBwYXJ0
cyBvZiB0aGUgY29kZSwNCj4gdGhlcmUgaXMgbm8gbmVlZCB0byBjaGVjayBhZ2FpbnN0IE5VTEwg
aW4gYSBzaW5nbGUgcGxhY2UuDQoNCk5BQ0suIMKgVGhpcyBpcyBub3QgdHJ1ZS4NCg0KSWYgbHFf
c3RhIGlzIE5VTEwsIGl0IG1lYW5zIHRoYXQgbXZtX3N0YSBpcyBhbHNvIE5VTEwuwqDCoFRoZW4g
d2UgY2FsbA0KdGhlIHJhdGVfY29udHJvbF9zZW5kIHdpdGggbXZtX3N0YSA9PSBOVUxMOg0KDQoJ
aWYgKHJhdGVfY29udHJvbF9zZW5kX2xvdyhzdGEsIG12bV9zdGEsIHR4cmMpKQ0KCQlyZXR1cm47
DQoNClRoZSByYXRlX2NvbnRyb2xfc2VuZF9sb3coKSBmdW5jdGlvbiBsb29rcyBsaWtlIHRoaXM6
DQoNCg0KYm9vbCByYXRlX2NvbnRyb2xfc2VuZF9sb3coc3RydWN0IGllZWU4MDIxMV9zdGEgKnB1
YnN0YSwNCgkJCcKgwqDCoHZvaWQgKnByaXZfc3RhLA0KCQkJwqDCoMKgc3RydWN0IGllZWU4MDIx
MV90eF9yYXRlX2NvbnRyb2wgKnR4cmMpDQp7DQpbLi4uXQ0KCWlmICghcHVic3RhIHx8ICFwcml2
X3N0YSB8fCByY19ub19kYXRhX29yX25vX2Fja191c2VfbWluKHR4cmMpKSB7DQpbLi4uXQ0KCQly
ZXR1cm4gdHJ1ZTsNCgl9DQpbLi4uXQ0KfQ0KDQoNCldoaWNoIG1lYW5zIHRoYXQgaWYgcHJpdl9z
dGEgKGFrYSBtdm1fc3RhKSBpcyBOVUxMLCB3ZSB3aWxsIHJldHVybg0Kd2l0aG91dCBydW5uaW5n
IHRoZSByZXN0IG9mIHJzX2dldF9yYXRlKCkgd2hlcmUgbHFfc3RhIGlzIGFjY2Vzc2VkDQp3aXRo
b3V0IGNoZWNrcy4NCg0KSSBhZG1pdCB0aGF0IHRoZSByc19nZXRfcmF0ZSgpIGZ1bmN0aW9uIGlz
IGEgYml0IGhhcmQgdG8gcmVhZCwgYnV0DQpyZW1vdmluZyB0aGUgbHFfc3RhIGNoZWNrIGFzIHlv
dSBkaWQgZG9lc24ndCBoZWxwLCBidXQgbWFrZXMgdGhpbmdzDQp3b3JzZS4NCg0KLS0NCkNoZWVy
cywNCkx1Y2Eu
