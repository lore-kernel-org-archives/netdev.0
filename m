From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: Re: [PATCH] [trivial] ixgbe: Fix format string in ixgbe_fcoe.c
Date: Tue, 21 Jan 2014 23:04:53 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B73142908@ORSMSX101.amr.corp.intel.com>
References: <1389716082-23395-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"trivial@kernel.org" <trivial@kernel.org>
To: "standby24x7@gmail.com" <standby24x7@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389716082-23395-1-git-send-email-standby24x7@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gV2VkLCAyMDE0LTAxLTE1IGF0IDAxOjE0ICswOTAwLCBNYXNhbmFyaSBJaWRhIHdyb3RlOgo+
IGNwcGNoZWNrIGRldGVjdGVkIGZvbGxvd2luZyB3YXJuaW5nIGluIGl4Z2JlX2Zjb2UuYwo+ICh3
YXJuaW5nKSAlZCBpbiBmb3JtYXQgc3RyaW5nIChuby4gMSkgcmVxdWlyZXMgJ2ludCcgYnV0IHRo
ZQo+IGFyZ3VtZW50IHR5cGUgaXMgJ3Vuc2lnbmVkIGludCcuCj4gCj4gU2lnbmVkLW9mZi1ieTog
TWFzYW5hcmkgSWlkYSA8c3RhbmRieTI0eDdAZ21haWwuY29tPgpUZXN0ZWQtQnk6IEphY2sgTW9y
Z2FuIDxqYWNrLm1vcmdhbkBpbnRlbC5jb20+ClNpZ25lZC1vZmYtYnk6IEFhcm9uIEJyb3duIDxh
YXJvbi5mLmJyb3duQGludGVsLmNvbT4KCj4gLS0tCj4gIGRyaXZlcnMvbmV0L2V0aGVybmV0L2lu
dGVsL2l4Z2JlL2l4Z2JlX2Zjb2UuYyB8IDIgKy0KPiAgMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0
aW9uKCspLCAxIGRlbGV0aW9uKC0pCj4gCj4gZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVy
bmV0L2ludGVsL2l4Z2JlL2l4Z2JlX2Zjb2UuYyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVs
L2l4Z2JlL2l4Z2JlX2Zjb2UuYwo+IGluZGV4IGY1OGRiNDUuLjA4NzI2MTcgMTAwNjQ0Cj4gLS0t
IGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmUvaXhnYmVfZmNvZS5jCj4gKysrIGIv
ZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmUvaXhnYmVfZmNvZS5jCj4gQEAgLTU4NSw3
ICs1ODUsNyBAQCBzdGF0aWMgaW50IGl4Z2JlX2Zjb2VfZG1hX3Bvb2xfYWxsb2Moc3RydWN0IGl4
Z2JlX2Zjb2UgKmZjb2UsCj4gIAlzdHJ1Y3QgZG1hX3Bvb2wgKnBvb2w7Cj4gIAljaGFyIHBvb2xf
bmFtZVszMl07Cj4gIAo+IC0Jc25wcmludGYocG9vbF9uYW1lLCAzMiwgIml4Z2JlX2Zjb2VfZGRw
XyVkIiwgY3B1KTsKPiArCXNucHJpbnRmKHBvb2xfbmFtZSwgMzIsICJpeGdiZV9mY29lX2RkcF8l
dSIsIGNwdSk7Cj4gIAo+ICAJcG9vbCA9IGRtYV9wb29sX2NyZWF0ZShwb29sX25hbWUsIGRldiwg
SVhHQkVfRkNQVFJfTUFYLAo+ICAJCQkgICAgICAgSVhHQkVfRkNQVFJfQUxJR04sIFBBR0VfU0la
RSk7CgoK
