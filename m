From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 11:56:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBD531B@AcuExch.aculab.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
	<20151117192738.365145d7@samsung9>
 <CAHo-OoyuH=XFFNs+J_s0ws_RsAXkzF5AuafFPaevg8UV35iT+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Lorenzo Colitti <lorenzo@google.com>,
	Linux NetDev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"ek@google.com" <ek@google.com>,
	"dtor@google.com" <dtor@google.com>
To: 'Maciej Zenczykowski' <zenczykowski@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.193]:60554 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbbKRL6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 06:58:10 -0500
In-Reply-To: <CAHo-OoyuH=XFFNs+J_s0ws_RsAXkzF5AuafFPaevg8UV35iT+w@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTWFjaWVqIFplbmN6eWtvd3NraQ0KPiBTZW50OiAxOCBOb3ZlbWJlciAyMDE1IDAzOjU3
DQo+IEkgZG9uJ3Qga25vdyB3aGF0IHRoZSByaWdodCBmaXggaXMuLi4NCj4gDQo+IEhvd2V2ZXIs
IHNwZWFraW5nIGFzIGFuIGVuZCB1c2VyIHdpdGggbGFwdG9wcyBvbiB3aWZpIGFuZC9vciBob21l
DQo+IGdhdGV3YXlzIG9uIGRpYWx1cCBjb25uZWN0aW9ucyB3aGVyZSB0aGUgSVAgYWRkcmVzcyBv
Y2Nhc2lvbmFsbHkgKG9yDQo+IGNvbnN0YW50bHkpIGNoYW5nZXMsIEkgZmluZCBpdCB2ZXJ5IGZy
dXN0cmF0aW5nIHRoYXQgYnkgZGVmYXVsdCBhcyBJUA0KPiBhZGRyZXNzZXMgZ2V0IHJlbW92ZWQg
ZnJvbSBpbnRlcmZhY2VzIGFsbCB0aGUgcmVsYXRlZCBzdGF0ZSAod2hldGhlcg0KPiBjb25udHJh
Y2sgb3Igb3BlbiBjb25uZWN0aW9ucykgZG9lc24ndCBnZXQgY2xlYW5lZCB1cC4NCg0KUmlnaHQs
IGJ1dCBJIGRvbid0IHdhbnQgaXQgaGFwcGVuaW5nIHdoZW4gYW4gaW50ZXJmYWNlIHRlbXBvcmFy
aWx5DQpnb2VzIGRvd24gZm9yIHNvbWUgcmVhc29uLg0KVHJpcCBvdmVyIHRoZSBjYWJsZSB0byBh
IFVTQiBuZXR3b3JrIGludGVyZmFjZSBhbmQgeW91IHdhbnQgdGhlIGNvbm5lY3Rpb25zDQp0byBz
dGlsbCBiZSBhbGl2ZSB3aGVuIHlvdSBwbHVnIGl0IGJhY2sgaW4uDQpXZSd2ZSBoYWQgdG8gcHV0
IFVTQiBpbnRlcmZhY2VzIGludG8gYSAnYm9uZCcgdG8gZ2V0IGEgc3RhYmxlIGFkZHJlc3MuDQoN
Ck5vdywgaWYgeW91IGhhdmUgYSBESENQIGFzc2lnbmVkIGFkZHJlc3MgeW91IG1heSB3YW50IHRv
IGZvcmNlIGENCmxlYXNlIHJlbmV3YWwgYWZ0ZXIgYSBuZXR3b3JrICdnbGl0Y2gnLiBJZiB5b3Ug
Z2V0IGJhY2sgYSBkaWZmZXJlbnQNCmFkZHJlc3MgdGhlbiBpdCBtaWdodCBiZSByZWFzb25hYmxl
IGZvciB0aGUgc3RhY2sgdG8gZXJyb3IgYW55DQpjb25uZWN0aW9ucyB1c2luZyB0aGUgb2xkIGFk
ZHJlc3MgLSBhZnRlciBhbGwgYW5vdGhlciBzeXN0ZW0NCmNvdWxkIGJlIHVzaW5nIHRoZSBvbGQg
SVAgYWRkcmVzcy4NCg0KSSBzdXNwZWN0IHRoYXQgdGhlIG9ubHkgd2F5IHRvIGF2b2lkIGhvcnJp
ZCB0aW1pbmcgd2luZG93cyBpcw0KdG8gc2ltdWxhdGUgdGhlIHJlY2VpcHQgb2YgUlNUIHBhY2tl
dHMuDQoNCglEYXZpZA0KDQo=
