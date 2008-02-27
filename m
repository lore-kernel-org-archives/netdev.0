From: Louis JANG <louis@mizi.com>
Subject: Re: [Bluez-devel] forcing SCO connection patch
Date: Wed, 27 Feb 2008 21:21:57 +0900
Message-ID: <47C555E5.2000903@mizi.com>
References: <47666E1F.2000902@mizi.com>	 <a8e1da0802242330l765b8b1ava62b857baf8a5568@mail.gmail.com>	 <47C28A33.4070102@mizi.com> <a8e1da0802250155u1b7af481va203849f68d9106b@mail.gmail.com> <47C2A7FA.2060902@mizi.com> <70692DDF-93B7-447E-ABEE-3CDBD94F15F1@holtmann.org> <47C38D40.3040809@mizi.com> <B96BD3FE-F490-4AD5-9315-ECD42CE9C728@holtmann.org> <47C4C3D4.8010902@mizi.com> <2A7EF87C-1340-45D7-B457-F81799674B1E@holtmann.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080202030206090505010301"
Cc: Dave Young <hidave.darkstar@gmail.com>,
	linux-bluetooth@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	bmidgley@gmail.com, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mizi.com ([61.107.31.33]:45396 "EHLO mail.mizi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754069AbYB0MWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 07:22:25 -0500
In-Reply-To: <2A7EF87C-1340-45D7-B457-F81799674B1E@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080202030206090505010301
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: 8bit

Marcel Holtmann ¾´ ±Û:
>
> so the patch is fine, but the description of what this patch is doing,
> why it is doing it this way and what it fixes is fully missing. Please
> update it with a proper description.
I added more information. please check it, and please let me know if
there are any missings.

Thanks
Louis JANG

>
> Regards
>
> Marcel


--------------080202030206090505010301
Content-Type: text/plain;
 name="patch_hci_event.c6"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="patch_hci_event.c6"

V2hlbiBibHVleiB0cmllZCB0byBjb25uZWN0IFNDTyBjaGFubmVsIHdpdGggSENJX09QX1NF
VFVQX1NZTkNfQ09OTihFU0NPX0xJTkspLCAKYSByZWFsIGNvbm5lY3Rpb24gbWF5IGJlIGNv
bm5lY3RlZCB3aXRoIFNDT19MSU5LIGluc3RlYWQgb2YgRVNDT19MSU5LIHdoZW4gCnBlZXIg
ZGV2aWNlIGRvZXNuJ3Qgc3VwcG9ydCBlU0NPLiAgaG93ZXZlciBibHVleiB0cnkgdG8gZmlu
ZCBjb25uZWN0aW9uIGhhbmRsZSAKYnkgZXZlbnQncyBsaW5rIHR5cGUoU0NPX0xJTksgaW4g
YWJvdmUgY2FzZSkgYW5kIHRoZSB2YWxpZCBjb25uZWN0aW9uIGhhbmRsZSAKZm9yIHRoaXMg
ZXZlbnQgaXMgd2FpdGluZyBmb3IgRVNDT19MSU5LLiBzbyBibHVleiBjYW4ndCBmaW5kIGNv
bm5lY3Rpb24gaGFuZGxlIAphbmQgZGlzY2FyZGVkIHRoZSBldmVudC4gCgpUaGlzIHBhdGNo
IGlzIHRvIGhhbmRsZSBkaWZmZXJlbnQgdHlwZSBvZiBzeW5jaHJvbm91cyBsaW5rIGlzIGVz
dGFiaWxpc2hlZCAKd2l0aCBpdHMgcmVxdWVzdC4gCgpJZiBibHVleiBjYW4ndCBmaW5kIGNv
bm5lY3Rpb24gaGFuZGxlLCBpdCB0cnkgdG8gZmluZCB3aXRoIGRpZmZlcmVudCAKbGluayB0
eXBlIGFnYWluLiAoRm9yIHRoZSBhYm92ZSBjYXNlLCBpZiBibHVleiBjYW4ndCBmaW5kIGNv
bm5lY3Rpb24gCmhhbmRsZSB3aXRoIFNDT19MSU5LLCBpdCB0cnkgdG8gZmluZCBjb25uZWN0
aW9uIGhhbmRsZSB3aXRoIEVTQ09fTElOSyBhZ2Fpbi4pCmFuZCB1cGRhdGUgbGluayB0eXBl
IG9mIHRoaXMgY29ubmVjdGlvbiBoYW5kbGUgd2l0aCBldmVudCdzIGxpbmsgdHlwZS4KClNp
Z25lZC1vZmYtYnk6IExvdWlzIEpBTkcgPGxvdWlzQG1pemkuY29tPgotLS0gbGludXgtMi42
LjIzL25ldC9ibHVldG9vdGgvaGNpX2V2ZW50LmMub3JpZwkyMDA4LTAyLTI2IDEyOjQ2OjM2
LjAwMDAwMDAwMCArMDkwMAorKysgbGludXgtMi42LjIzL25ldC9ibHVldG9vdGgvaGNpX2V2
ZW50LmMJMjAwOC0wMi0yNyAxMDo0ODoyOS4wMDAwMDAwMDAgKzA5MDAKQEAgLTEzMTMsOCAr
MTMxMywxNSBAQAogCWhjaV9kZXZfbG9jayhoZGV2KTsKIAogCWNvbm4gPSBoY2lfY29ubl9o
YXNoX2xvb2t1cF9iYShoZGV2LCBldi0+bGlua190eXBlLCAmZXYtPmJkYWRkcik7Ci0JaWYg
KCFjb25uKQotCQlnb3RvIHVubG9jazsKKwlpZiAoIWNvbm4pIHsKKwkJX191OCBsaW5rX3R5
cGUgPSAoZXYtPmxpbmtfdHlwZSA9PSBFU0NPX0xJTkspID8gU0NPX0xJTksgOiBFU0NPX0xJ
Tks7CisKKwkJY29ubiA9IGhjaV9jb25uX2hhc2hfbG9va3VwX2JhKGhkZXYsIGxpbmtfdHlw
ZSwgJmV2LT5iZGFkZHIpOworCQlpZiAoIWNvbm4pCisJCQlnb3RvIHVubG9jazsKKworCQlj
b25uLT50eXBlID0gZXYtPmxpbmtfdHlwZTsKKwl9CiAKIAlpZiAoIWV2LT5zdGF0dXMpIHsK
IAkJY29ubi0+aGFuZGxlID0gX19sZTE2X3RvX2NwdShldi0+aGFuZGxlKTsK
--------------080202030206090505010301--
