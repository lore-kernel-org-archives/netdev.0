From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: Unsigned widening casts of binary "not" operations..
Date: Tue, 23 Apr 2013 09:59:05 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B71EF@saturn3.aculab.com>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com> <CA+55aFy0jPr5udwJx8cZ-QFs-OgZzQ_NJm_VSj_cS7tsKUn3Kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	"Network Development" <netdev@vger.kernel.org>,
	<linux-ext4@vger.kernel.org>
To: "Linus Torvalds" <torvalds@linux-foundation.org>,
	"Ingo Molnar" <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"David Miller" <davem@davemloft.net>,
	"Theodore Ts'o" <tytso@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57504 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754726Ab3DWJAS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 05:00:18 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12343-01 for <netdev@vger.kernel.org>;
 Tue, 23 Apr 2013 10:00:15 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <CA+55aFy0jPr5udwJx8cZ-QFs-OgZzQ_NJm_VSj_cS7tsKUn3Kw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBXaGF0IGhhcHBlbnMgaXMgdGhhdCB0aGUgIn5iaXRtYXNrIiBpcyBkb25lIGluIHRoZSAqbmFy
cm93ZXIqIHR5cGUsDQo+IGFuZCB0aGVuIC0gYmVjYXVzZSB0aGUgbmFycm93ZXIgdHlwZSBpcyB1
bnNpZ25lZCAtIHRoZSBjYXN0IHRvIHRoZQ0KPiB3aWRlciB0eXBlIGlzIGRvbmUgYXMgYW4gKnVu
c2lnbmVkKiBjYXN0LCBzbyB3aGF0IHlvdSAqdGhpbmsqIGhhcHBlbnMNCj4gaXMgdGhhdCBpdCBj
bGVhcnMgdGhlIGJpdHMgdGhhdCBhcmUgc2V0IGluICJiaXRtYXNrIiwgYnV0IHdoYXQNCj4gKmFj
dHVhbGx5KiBoYXBwZW5zIGlzIHRoYXQgeWVzLCB5b3UgY2xlYXIgdGhlIGJpdHMgdGhhdCBhcmUg
c2V0IGluDQo+IDpiaXRtYXNrIiwgYnV0IHlvdSAqYWxzbyogY2xlYXIgdGhlIHVwcGVyIGJpdHMg
b2YgdmFsdWUuDQoNCklmIHRoZSBuYXJyb3dlciB0eXBlIGlzIHNpZ25lZCBpdCBpcyBwcm9iYWJs
eSBldmVuIG1vcmUgY29uZnVzaW5nIQ0KVGhlIGhpZ2ggYml0cyB3aWxsIGJlIHByZXNlcnZlZCB1
bmxlc3MgeW91IGFyZSBtYXNraW5nIG9mZiBiaXQgMzEuDQoNCglEYXZpZA0KDQo=
