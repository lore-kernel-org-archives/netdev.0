From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: Intel 82574L hang when sending short ethernet packets at
 100BaseT
Date: Wed, 5 Sep 2012 21:12:20 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA89130DBB510@ORSMSX102.amr.corp.intel.com>
References: <87k3whtqci.fsf@kwong-desktop.i-did-not-set--mail-host-address--so-tickle-me>
	<061C8A8601E8EE4CA8D8FD6990CEA89130DB6077@ORSMSX102.amr.corp.intel.com>
	<CAK2bC5q5NcWj5vsmPB1GekUpON_R_mTWgkEAYBgBZSJZ30GcDg@mail.gmail.com>
	<061C8A8601E8EE4CA8D8FD6990CEA89130DB60AC@ORSMSX102.amr.corp.intel.com>
 <CAK2bC5oMnxerNYsgoD7WFJ6p84=BqaZLFdt+GdO91tF0gmyg2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Kelvie Wong <kwong@wurldtech.com>
To: Kelvie Wong <kelvie@ieee.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37324 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759287Ab2IEVMW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 17:12:22 -0400
In-Reply-To: <CAK2bC5oMnxerNYsgoD7WFJ6p84=BqaZLFdt+GdO91tF0gmyg2w@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbToga2VsdmllQGdtYWlsLmNvbSBbbWFp
bHRvOmtlbHZpZUBnbWFpbC5jb21dIE9uIEJlaGFsZiBPZiBLZWx2aWUgV29uZw0KPlNlbnQ6IFdl
ZG5lc2RheSwgQXVndXN0IDI5LCAyMDEyIDE6NDYgUE0NCj5UbzogRGF2ZSwgVHVzaGFyIE4NCj5D
YzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgZTEwMDAtZGV2ZWxAbGlzdHMuc291cmNlZm9yZ2Uu
bmV0OyBLZWx2aWUgV29uZw0KPlN1YmplY3Q6IFJlOiBJbnRlbCA4MjU3NEwgaGFuZyB3aGVuIHNl
bmRpbmcgc2hvcnQgZXRoZXJuZXQgcGFja2V0cyBhdA0KPjEwMEJhc2VUDQo+DQo+T24gV2VkLCBB
dWcgMjksIDIwMTIgYXQgMToyOSBQTSwgRGF2ZSwgVHVzaGFyIE4gPHR1c2hhci5uLmRhdmVAaW50
ZWwuY29tPg0KPndyb3RlOg0KPj4gSSdtIGFscmVhZHkgYXdhcmUgb2YgdGhpcyBpc3N1ZSBvbiBQ
Q0kvUENJLVggcGFydHMgYW5kIGUxMDAwIFNGIGRyaXZlcg0KPmRvZXMgaGF2ZSB0aGlzIFdBIGlt
cGxlbWVudGVkLiBUaGUgcGF0Y2ggZm9yIHVwc3RyZWFtIGUxMDAwIGRyaXZlciBpcw0KPnN1Ym1p
dHRlZCB0b28gd2hpY2ggd2lsbCBiZSBhY2NlcHRlZCBzb29uLg0KPj4gSSB3aWxsIGNoZWNrIHdp
dGggdGVhbSBhbmQgc2VlIGlmIHdlIG5lZWQgc2ltaWxhciBXQSBmb3IgUENJZSBwYXJ0KHMpIQ0K
Pg0KPkFoLCBJIHNlZS4gVGhhbmtzIGZvciB0aGUgY2xhcmlmaWNhdGlvbi4NCg0KVGhhbmtzIGZv
ciB5b3VyIHBhdGllbmNlLg0KSXQgaXMgY29uZmlybWVkIHRoYXQgbWluaW11bSAxNyBieXRlcyBv
ZiBwYWNrZXQgc2l6ZSBpcyBhIEhXIHJlcXVpcmVtZW50IGZvciBhbGwgb2Ygb3VyIFBDSS9QQ0kt
WC9QQ0llIHBhcnRzLg0KTmV4dCByZWxlYXNlIG9mIGFsbCBvdXIgZHJpdmVycyAoZTEwMDAsIGUx
MDAwZSAsIGlnYiBhbmQgaXhnYmUpICB3aWxsIGhhdmUgdGhpcyBmaXhlZC4NCg0KLVR1c2hhcg0K
IA0K
