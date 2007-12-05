From: "Ian Brown" <ianbrn@gmail.com>
Subject: Re: [PATCH] correct typo in __xfrm4_bundle_create()
Date: Wed, 5 Dec 2007 15:41:37 +0200
Message-ID: <d0383f90712050541p5d8ffce6q8748d7c6b66ea9c6@mail.gmail.com>
References: <d0383f90712050249q3bc0e249h4cb66dc0ea97f172@mail.gmail.com>
	 <20071205.052034.251196808.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_3280_1811923.1196862097808"
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:53153 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbXLENlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 08:41:39 -0500
Received: by py-out-1112.google.com with SMTP id u77so62321pyb
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2007 05:41:38 -0800 (PST)
In-Reply-To: <20071205.052034.251196808.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_3280_1811923.1196862097808
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,
Sorry; I was not aware of it; I am sending here  the patch as an attachment.
It is a typo correction in __xfrm4_bundle_create() in net/ipv4/xfrm4_policy.c;
 it should be "Copy neighbour" instead "Copy neighbout"
Ian


On Dec 5, 2007 3:20 PM, David Miller <davem@davemloft.net> wrote:
> From: "Ian Brown" <ianbrn@gmail.com>
> Date: Wed, 5 Dec 2007 12:49:52 +0200
>
> >  This is a typo correction in net/ipv4/xfrm4_policy.c; it should be
> > "Copy neighbour" instead "Copy neighbout",
>
> Your email client has corrupted the patch by adding
> newlines among other things.
>
> This happens often for gmail users, because by default
> gmail does text formatting which you don't want it
> to do for patches because it corrupts them.
>
> Please use an attachment or some other method to prevent
> this form happening so that you patch is not corrupted.
>

------=_Part_3280_1811923.1196862097808
Content-Type: text/plain; name=patchToNetDev.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f9twqd5h0
Content-Disposition: attachment; filename=patchToNetDev.txt

U2lnbmVkLW9mZi1ieTogaWFuYnJuQGdtYWlsLmNvbQoKZGlmZiAtLWdpdCBhL2EvbmV0L2lwdjQv
eGZybTRfcG9saWN5LmMgYi9iL25ldC9pcHY0L3hmcm00X3BvbGljeS5jCmluZGV4IGNjODZmYjEu
LjM5MGRjN2MgMTAwNjQ0Ci0tLSBhL2EvbmV0L2lwdjQveGZybTRfcG9saWN5LmMKKysrIGIvYi9u
ZXQvaXB2NC94ZnJtNF9wb2xpY3kuYwpAQCAtMTY1LDcgKzE2NSw3IEBAIF9feGZybTRfYnVuZGxl
X2NyZWF0ZShzdHJ1Y3QgeGZybV9wb2xpY3kgKnBvbGljeSwgc3RydWN0IHhmcm1fc3RhdGUgKip4
ZnJtLCBpbnQKIAkJZHN0X3ByZXYtPnRyYWlsZXJfbGVuCT0gdHJhaWxlcl9sZW47CiAJCW1lbWNw
eSgmZHN0X3ByZXYtPm1ldHJpY3MsICZ4LT5yb3V0ZS0+bWV0cmljcywgc2l6ZW9mKGRzdF9wcmV2
LT5tZXRyaWNzKSk7CiAKLQkJLyogQ29weSBuZWlnaGJvdXQgZm9yIHJlYWNoYWJpbGl0eSBjb25m
aXJtYXRpb24gKi8KKwkJLyogQ29weSBuZWlnaGJvdXIgZm9yIHJlYWNoYWJpbGl0eSBjb25maXJt
YXRpb24gKi8KIAkJZHN0X3ByZXYtPm5laWdoYm91cgk9IG5laWdoX2Nsb25lKHJ0LT51LmRzdC5u
ZWlnaGJvdXIpOwogCQlkc3RfcHJldi0+aW5wdXQJCT0gcnQtPnUuZHN0LmlucHV0OwogCQlkc3Rf
cHJldi0+b3V0cHV0ID0gZHN0X3ByZXYtPnhmcm0tPm91dGVyX21vZGUtPmFmaW5mby0+b3V0cHV0
OwoJCQoK
------=_Part_3280_1811923.1196862097808--
