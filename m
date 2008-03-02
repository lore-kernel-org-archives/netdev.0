From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: assertion (packets <= tp->packets_out) failed
Date: Sun, 2 Mar 2008 09:15:41 -0800
Message-ID: <2c0942db0803020915y438bd922h8022267f6f7914fe@mail.gmail.com>
References: <2c0942db0803011510s5cfc30cbhee8ac9c1b849a2aa@mail.gmail.com>
	 <Pine.LNX.4.64.0803021041560.17707@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: "kernel list" <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: "=?UTF-8?Q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:34260 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754740AbYCBRPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 12:15:43 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1486180ugc.16
        for <netdev@vger.kernel.org>; Sun, 02 Mar 2008 09:15:41 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0803021041560.17707@kivilampi-30.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gU3VuLCBNYXIgMiwgMjAwOCBhdCAxMjo0NCBBTSwgSWxwbyBKw6RydmluZW4KPGlscG8uamFy
dmluZW5AaGVsc2lua2kuZmk+IHdyb3RlOgo+IE9uIFNhdCwgMSBNYXIgMjAwOCwgUmF5IExlZSB3
cm90ZToKPgo+ICA+IFdpcmVsZXNzIGJlbG93IGlzIGI0Mywgd2lyZWQgaW50ZXJmYWNlICh0ZzMp
IHdhcyBkaXNjb25uZWN0ZWQuIEkgcnVuCj4gID4gb3BlbnZwbiB3aGljaCB1c2VzIGEgdHVuIGlu
dGVyZmFjZSBhbmQgcmVndWxhcmx5IHNlbmRzIGEgaGVhcnRiZWF0Cj4gID4gZXZlbiB3aGVuIG5v
dCBpbiB1c2UuIFRoZSB0cmFjZSBhcHBlYXJlZCB0d2ljZS4KPiAgPgo+ICA+IExpa2VseSB1bnJl
bGF0ZWQgYnV0IHJlcG9ydGluZyBqdXN0IGZvciBjb21wbGV0ZW5lc3M6IGFib3V0IGZpZnRlZW4K
PiAgPiBtaW51dGVzIGFmdGVyIHRoaXMgdGhlIHN5c3RlbSBvb3BzZWQgd2hlbiBJIHRvbGQgbXkg
d2lyZWxlc3MgYmFzZQo+ICA+IHN0YXRpb24gdG8gc3dpdGNoIGZyb20gbWl4ZWQgQi9HIHRvIGp1
c3QgQi4gSSdsbCBiZSB0YWtpbmcgdGhhdCB1cAo+ICA+IHNlcGFyYXRlbHkgd2l0aCB0aGUgYmNt
NDN4eCBsaXN0Lgo+ICA+Cj4gID4gTWFyICAxIDExOjA2OjM3IHBob2VuaXgga2VybmVsOiBbMzUy
NTEuMjA4Mjc1XSBldGgxOiBzd2l0Y2hlZCB0byBzaG9ydAo+ICA+IGJhcmtlciBwcmVhbWJsZSAo
QlNTSUQ9MDA6MTY6MDE6ZDE6NDQ6M2UpCj4gID4gTWFyICAxIDExOjA2OjM3IHBob2VuaXgga2Vy
bmVsOiBbMzUyNTEuMzIwMjgyXSBldGgxOiBzd2l0Y2hlZCB0byBsb25nCj4gID4gYmFya2VyIHBy
ZWFtYmxlIChCU1NJRD0wMDoxNjowMTpkMTo0NDozZSkKPiAgPiBNYXIgIDEgMTE6MDg6MjggcGhv
ZW5peCBrZXJuZWw6IFszNTI3NC4zOTYxNjNdIEtFUk5FTDogYXNzZXJ0aW9uCj4gID4gKHBhY2tl
dHMgPD0gdHAtPnBhY2tldHNfb3V0KSBmYWlsZWQgYXQgbmV0L2lwdjQvdGNwX2lucHV0LmMgKDIx
MzkpCj4gID4gTWFyICAxIDExOjA4OjI5IHBob2VuaXgga2VybmVsOiBbMzUyNzQuNDA2MTI2XSAt
LS0tLS0tLS0tLS1bIGN1dCBoZXJlCj4gID4gXS0tLS0tLS0tLS0tLQo+ICA+IE1hciAgMSAxMTow
ODoyOSBwaG9lbml4IGtlcm5lbDogWzM1Mjc0LjQwNjEzMl0gV0FSTklORzogYXQKPiAgPiBuZXQv
aXB2NC90Y3BfaW5wdXQuYzoyNTA2IHRjcF9hY2srMHhlM2YvMHgxYjEyKCkKPgo+ICBEbyBwZW9w
bGUgZXZlciBsb29rIGludG8gYXJjaGl2ZXMgYmVmb3JlIHBvc3Rpbmc/IEknbSBhIGJpdCB0aXJl
ZCBvZiBwb2ludAo+ICB0byB0aGUgZGVidWcgcGF0Y2g6Cj4KPiAgaHR0cDovL21hcmMuaW5mby8/
bD1saW51eC1rZXJuZWwmbT0xMjA0MTg3MDMwMjMxNTMmdz0yCgpJJ20gc29ycnksIEkgbWFuYWdl
ZCB0byBtaXNzIGl0LiBJJ2xsIGFwcGx5IHRoZSBwYXRjaCBhbmQgcmVwb3J0IGJhY2suCgpUaGFu
ayB5b3UuCg==
