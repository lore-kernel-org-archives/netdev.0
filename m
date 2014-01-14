From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: Re: [PATCH 09/15] net: ixgbe calls skb_set_hash
Date: Tue, 14 Jan 2014 02:26:50 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B7312BE63@ORSMSX101.amr.corp.intel.com>
References: <alpine.DEB.2.02.1312172324380.24772@tomh.mtv.corp.google.com>
 <CAL3LdT7HC0EcYdbTxYe6OEy_cy6EbL1udafhwJA1VWCFv5gG1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"therbert@google.com" <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50809 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974AbaANC0w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jan 2014 21:26:52 -0500
In-Reply-To: <CAL3LdT7HC0EcYdbTxYe6OEy_cy6EbL1udafhwJA1VWCFv5gG1w@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gV2VkLCAyMDEzLTEyLTE4IGF0IDAwOjQxIC0wODAwLCBKZWZmIEtpcnNoZXIgd3JvdGU6Cj4g
T24gVHVlLCBEZWMgMTcsIDIwMTMgYXQgMTE6MjggUE0sIFRvbSBIZXJiZXJ0IDx0aGVyYmVydEBn
b29nbGUuY29tPiB3cm90ZToKPiA+IERyaXZlcnMgc2hvdWxkIGNhbGwgc2tiX3NldF9oYXNoIHRv
IHNldCB0aGUgaGFzaCBhbmQgaXRzIHR5cGUKPiA+IGluIGFuIHNrYnVmZi4KPiA+Cj4gPiBTaWdu
ZWQtb2ZmLWJ5OiBUb20gSGVyYmVydCA8dGhlcmJlcnRAZ29vZ2xlLmNvbT4KPiA+IC0tLQo+ID4g
IGRyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2l4Z2JlL2l4Z2JlX21haW4uYyB8IDQgKysrLQo+
ID4gIDEgZmlsZSBjaGFuZ2VkLCAzIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkKPiA+Cj4g
Cj4gSSBoYXZlIGFkZGVkIHRoaXMgcGF0Y2ggdG8gbXkgcXVldWUsIHRoYW5rcyBUb20uCgpTaWdu
ZWQtb2ZmIGJ5OiBBYXJvbiBCcm93biA8YWFyb24uZi5icm93bkBpbnRlbC5jb20+ClRlc3RlZC1i
eTogUGhpbCBTY2htaXR0IDxwaGlsbGlwLmouc2NobWl0dEBpbnRlbC5jb20+Cg==
