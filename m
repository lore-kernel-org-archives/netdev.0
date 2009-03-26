From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: Add support for the OpenCores 10/100 Mbps
 Ethernet MAC.
Date: Thu, 26 Mar 2009 00:55:45 -0700 (PDT)
Message-ID: <20090326.005545.180326952.davem@davemloft.net>
References: <20090325.171813.19940151.davem@davemloft.net>
	<1238053359-18896-1-git-send-email-thierry.reding@avionic-design.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thierry.reding@avionic-design.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41255
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752991AbZCZHz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 03:55:57 -0400
In-Reply-To: <1238053359-18896-1-git-send-email-thierry.reding@avionic-design.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVGhpZXJyeSBSZWRpbmcgPHRoaWVycnkucmVkaW5nQGF2aW9uaWMtZGVzaWduLmRlPg0K
RGF0ZTogVGh1LCAyNiBNYXIgMjAwOSAwODo0MjozOSArMDEwMA0KDQo+IFRoaXMgcGF0Y2ggYWRk
cyBhIHBsYXRmb3JtIGRldmljZSBkcml2ZXIgdGhhdCBzdXBwb3J0cyB0aGUgT3BlbkNvcmVzIDEw
LzEwMA0KPiBNYnBzIEV0aGVybmV0IE1BQy4NCj4gDQo+IFRoZSBkcml2ZXIgZXhwZWN0cyB0aHJl
ZSByZXNvdXJjZXM6IG9uZSBJT1JFU09VUkNFX01FTSByZXNvdXJjZSBkZWZpbmVzIHRoZQ0KPiBt
ZW1vcnkgcmVnaW9uIGZvciB0aGUgY29yZSdzIG1lbW9yeS1tYXBwZWQgcmVnaXN0ZXJzIHdoaWxl
IGEgc2Vjb25kDQo+IElPUkVTT1VSQ0VfTUVNIHJlc291cmNlIGRlZmluZXMgdGhlIG5ldHdvcmsg
cGFja2V0IGJ1ZmZlciBzcGFjZS4gVGhlIHRoaXJkDQo+IHJlc291cmNlLCBvZiB0eXBlIElPUkVT
T1VSQ0VfSVJRLCBhc3NvY2lhdGVzIGFuIGludGVycnVwdCB3aXRoIHRoZSBkcml2ZXIuDQo+IA0K
PiBTaWduZWQtb2ZmLWJ5OiBUaGllcnJ5IFJlZGluZyA8dGhpZXJyeS5yZWRpbmdAYXZpb25pYy1k
ZXNpZ24uZGU+DQo+IEFja2VkLWJ5OiBGbG9yaWFuIEZhaW5lbGxpIDxmbG9yaWFuQG9wZW53cnQu
b3JnPg0KDQpUaGlzIGRvZXNuJ3QgYnVpbGQ6DQoNCmRyaXZlcnMvbmV0L2V0aG9jLmM6IEluIGZ1
bmN0aW9uIOKAmGV0aG9jX2ludGVycnVwdOKAmToNCmRyaXZlcnMvbmV0L2V0aG9jLmM6NTEwOiBl
cnJvcjogaW1wbGljaXQgZGVjbGFyYXRpb24gb2YgZnVuY3Rpb24g4oCYbmV0aWZfcnhfc2NoZWR1
bGVfcHJlcOKAmQ0KZHJpdmVycy9uZXQvZXRob2MuYzo1MTE6IGVycm9yOiBpbXBsaWNpdCBkZWNs
YXJhdGlvbiBvZiBmdW5jdGlvbiDigJhfX25ldGlmX3J4X3NjaGVkdWxl4oCZDQpkcml2ZXJzL25l
dC9ldGhvYy5jOiBJbiBmdW5jdGlvbiDigJhldGhvY19wb2xs4oCZOg0KZHJpdmVycy9uZXQvZXRo
b2MuYzo1NTA6IGVycm9yOiBpbXBsaWNpdCBkZWNsYXJhdGlvbiBvZiBmdW5jdGlvbiDigJhuZXRp
Zl9yeF9jb21wbGV0ZeKAmQ0KDQpZb3UgYXJlIG1pc3Npbmcgc29tZSBoZWFkZXIgaW5jbHVkZXMu
DQo=
