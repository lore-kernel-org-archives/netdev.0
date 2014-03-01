From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: Re: [PATCH net-next v2] ixgbevf: fix skb->pkt_type checks
Date: Sat, 1 Mar 2014 00:12:05 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B73162FE8@ORSMSX101.amr.corp.intel.com>
References: <1393631209-5991-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30863 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751787AbaCAAMH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 19:12:07 -0500
In-Reply-To: <1393631209-5991-1-git-send-email-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gRnJpLCAyMDE0LTAyLTI4IGF0IDE1OjQ2IC0wODAwLCBGbG9yaWFuIEZhaW5lbGxpIHdyb3Rl
Ogo+IHNrYi0+cGt0X3R5cGUgaXMgbm90IGEgYml0bWFzaywgYnV0IGNvbnRhaW5zIG9ubHkgdmFs
dWUgYXQgYSB0aW1lIGZyb20KPiB0aGUgcmFuZ2UgZGVmaW5lZCBpbiBpbmNsdWRlL3VhcGkvbGlu
dXgvaWZfcGFja2V0LmguCj4gCj4gQ2hlY2tpbmcgaXQgbGlrZSBpZiBpdCB3YXMgYSBiaXRtYXNr
IG9mIHZhbHVlcyB3b3VsZCBhbHNvIGNhdXNlCj4gUEFDS0VUX09USEVSSE9TVCwgUEFDS0VUX0xP
T1BCQUNLIGFuZCBQQUNLRVRfRkFTVFJPVVRFIHRvIGJlIG1hdGNoZWQgYnkKPiB0aGlzIGNoZWNr
IHNpbmNlIHRoZWlyIGxvd2VyIDIgYml0cyBhcmUgYWxzbyBzZXQsIGFsdGhvdWdoIHRoYXQgZG9l
cyBub3QKPiBmaXggYSByZWFsIGJ1ZywgaXQgaXMgc3RpbGwgcG90ZW50aWFsbHkgY29uZnVzaW5n
Lgo+IAo+IFRoaXMgYm9ndXMgY2hlY2sgd2FzIGludHJvZHVjZWQgaW4gY29tbWl0IDgxNWNjY2Jm
ICgiaXhnYmU6IGFkZCBzZXRsaW5rLAo+IGdldGxpbmsgc3VwcG9ydCB0byBpeGdiZSBhbmQgaXhn
YmV2ZiIpLgo+IAo+IFNpZ25lZC1vZmYtYnk6IEZsb3JpYW4gRmFpbmVsbGkgPGYuZmFpbmVsbGlA
Z21haWwuY29tPgo+IC0tLQo+IENoYW5nZXMgaW4gdjI6Cj4gLSBwcm9wZXJseSByZXNvbHZlIHRo
ZSByZWJhc2UsIGZpeGVzIHRoZSBidWlsZCBmYWlsdXJlIGluIHYxCgpUaGFua3MgRmxvcmlhbiwg
SSBoYXZlIHB1bGxlZCB0aGlzIG9uZSBpbnRvIG91ciBpbnRlcm5hbCBxdWV1ZSAoYW5kIHllcwpp
dCBjb21waWxlcyBmaW5lLikK
