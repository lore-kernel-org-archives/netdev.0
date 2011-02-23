From: Xiong Huang <Xiong.Huang@Atheros.com>
Subject: RE: Bug#614622: linux-image-2.6.37-1-686: atl2 NIC claims NO
 CARRIER after suspend/resume; rmmod+insmod fixes the problem
Date: Wed, 23 Feb 2011 09:38:52 +0800
Message-ID: <0FBC7C9C2640634A8B837C2EFFCFF32F01837E4A63@SHEXMB-01.global.atheros.com>
References: <20110222180821.5217.2375.reportbug@localhost.localdomain>
 <1298423651.2211.496.camel@localhost>
 <0FBC7C9C2640634A8B837C2EFFCFF32F01837E4A48@SHEXMB-01.global.atheros.com>
 <4D64643C.1020001@fifthhorseman.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	"614622@bugs.debian.org" <614622@bugs.debian.org>,
	Cloud Ren <Cloud.Ren@Atheros.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shgateway.atheros.com ([203.110.175.210]:38311 "EHLO
	mail.atheros.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753431Ab1BWBi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 20:38:56 -0500
In-Reply-To: <4D64643C.1020001@fifthhorseman.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgRGFuaWVsDQoNCiAgIFdoYXQgSSBtZWFuIGlzIHRvIGNoZWNrIGlmIHRoZSBjYWJsZSBsaW5r
ICh5b3UgY2FuIGNoZWNrIHRoZSBwZWVyIGxpbmsgTEVEIGlmIHlvdXIgb25ib2FyZCBOSUMgaGF2
ZW4ndCkgaXMgT04uDQpJZiB0aGUgY2FibGUgbGluayBpcyBPTiwgd2UgbWF5IGZvY3VzIG9uIHNv
ZnR3YXJlIGxheWVyIDopDQoNClRoYW5rcw0KWGlvbmcNCi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0t
LS0tDQpGcm9tOiBEYW5pZWwgS2FobiBHaWxsbW9yIFttYWlsdG86ZGtnQGZpZnRoaG9yc2VtYW4u
bmV0XSANClNlbnQ6IFdlZG5lc2RheSwgRmVicnVhcnkgMjMsIDIwMTEgOTozNQ0KVG86IFhpb25n
IEh1YW5nDQpDYzogQmVuIEh1dGNoaW5nczsgSmF5IENsaWJ1cm47IENocmlzIFNub29rOyBKaWUg
WWFuZzsgNjE0NjIyQGJ1Z3MuZGViaWFuLm9yZzsgbmV0ZGV2DQpTdWJqZWN0OiBSZTogQnVnIzYx
NDYyMjogbGludXgtaW1hZ2UtMi42LjM3LTEtNjg2OiBhdGwyIE5JQyBjbGFpbXMgTk8gQ0FSUklF
UiBhZnRlciBzdXNwZW5kL3Jlc3VtZTsgcm1tb2QraW5zbW9kIGZpeGVzIHRoZSBwcm9ibGVtDQoN
CkhpIFhpb25nLA0KDQpPbiAwMi8yMi8yMDExIDA4OjIyIFBNLCBYaW9uZyBIdWFuZyB3cm90ZToN
Cj4gYWZ0ZXIgdGhlIG9uYm9hcmQgTklDIGNsYWltcyBOTyBDYXJyaWVyIGFmdGVyIHJlc3VtaW5n
IGZyb20gc3VzcGVuZC10by1SQU0sIGhvdyBhYm91dCBpdCBpZiB1bnBsdWcgdGhlbiByZS1wbHVn
IHRoZSBjYWJsZSA/DQoNCmkndmUgdHJpZWQgdGhhdCwgYW5kIGl0IGlzIG5vdCBzdWZmaWNpZW50
IHRvIHJlbW92ZSB0aGUgTk8gQ0FSUklFUiBmbGFnIGZyb20gdGhlIG91dHB1dCBvZiAiaXAgbGlu
ayIuICBJJ3ZlIGFsc28gdHJpZWQgcG93ZXItY3ljbGluZyB0aGUgMTAvMTAwIG1pbmlzd2l0Y2gg
b24gdGhlIG90aGVyIGVuZCBvZiB0aGUgZXRoZXJuZXQgY2FibGUsIGJ1dCBubyBsdWNrIHRoZXJl
IGVpdGhlci4NCg0KU28gZmFyLCB0aGUgb25seSB0aGluZyBpJ3ZlIGZvdW5kIHRoYXQgY2xlYXJz
IHRoZSBOTyBDQVJSSUVSIHN0YXRlIGlzIHRvIHJlbW92ZSBhbmQgcmUtaW5zZXJ0IGF0bDIua28u
DQoNCkkgcmVtYWluIG9wZW4gdG8gb3RoZXIgc3VnZ2VzdGlvbnMuICBBbmQgdGhhbmtzIGZvciB0
aGUgc3BlZWR5IGZvbGxvd3VwIQ0KDQoJLS1ka2cNCg0K
