From: "Lucas C. Villa Real" <lucasvr@gobolinux.org>
Subject: [PATCH] iputils build fix
Date: Fri, 5 Nov 2010 17:49:39 -0200
Message-ID: <AANLkTikrxk2zTJffVvjjez=4c9na=4ioVOgQ4pD61qWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001517511d3a30eaeb0494539342
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:56758 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712Ab0KETtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 15:49:40 -0400
Received: by qyk10 with SMTP id 10so2987442qyk.19
        for <netdev@vger.kernel.org>; Fri, 05 Nov 2010 12:49:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001517511d3a30eaeb0494539342
Content-Type: text/plain; charset=ISO-8859-1

Hi,

Please find attached a patch which fixes the build of
iputils-s20101006 on platforms that don't have the SO_MARK operation.

Thanks,
Lucas

--001517511d3a30eaeb0494539342
Content-Type: application/octet-stream; name="01-iputils-SO_MARK.patch"
Content-Disposition: attachment; filename="01-iputils-SO_MARK.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gg5h7nwf0

Rml4ZXMgYnVpbGQgb24gcGxhdGZvcm1zIHdoZXJlIFNPX01BUksgaXMgbm90IGRlZmluZWQuCgpT
aWduZWQtb2ZmLWJ5OiBMdWNhcyBDLiBWaWxsYSBSZWFsIDxsdWNhc3ZyQHVzLmlibS5jb20+Cgpk
aWZmIC11cnAgaXB1dGlscy1zMjAxMDEwMDYub3JpZy9waW5nX2NvbW1vbi5jIGlwdXRpbHMtczIw
MTAxMDA2L3BpbmdfY29tbW9uLmMKLS0tIGlwdXRpbHMtczIwMTAxMDA2Lm9yaWcvcGluZ19jb21t
b24uYwkyMDEwLTEwLTA2IDA4OjU5OjIwLjAwMDAwMDAwMCAtMDMwMAorKysgaXB1dGlscy1zMjAx
MDEwMDYvcGluZ19jb21tb24uYwkyMDEwLTExLTA1IDE2OjA4OjA2LjAwMDAwMDAwMCAtMDIwMApA
QCAtNDc1LDYgKzQ3NSw3IEBAIHZvaWQgc2V0dXAoaW50IGljbXBfc29jaykKIAkJCWZwcmludGYo
c3RkZXJyLCAiV2FybmluZzogbm8gU09fVElNRVNUQU1QIHN1cHBvcnQsIGZhbGxpbmcgYmFjayB0
byBTSU9DR1NUQU1QXG4iKTsKIAl9CiAjZW5kaWYKKyNpZmRlZiBTT19NQVJLCiAJaWYgKG9wdGlv
bnMgJiBGX01BUkspIHsKIAkJaWYgKHNldHNvY2tvcHQoaWNtcF9zb2NrLCBTT0xfU09DS0VULCBT
T19NQVJLLAogCQkJCSZtYXJrLCBzaXplb2YobWFyaykpID09IC0xKSB7CkBAIC00ODQsNiArNDg1
LDcgQEAgdm9pZCBzZXR1cChpbnQgaWNtcF9zb2NrKQogCQkJZnByaW50ZihzdGRlcnIsICJXYXJu
aW5nOiBGYWlsZWQgdG8gc2V0IG1hcmsgJWRcbiIsIG1hcmspOwogCQl9CiAJfQorI2VuZGlmCiAK
IAkvKiBTZXQgc29tZSBTTkRUSU1FTyB0byBwcmV2ZW50IGJsb2NraW5nIGZvcmV2ZXIKIAkgKiBv
biBzZW5kcywgd2hlbiBkZXZpY2UgaXMgdG9vIHNsb3cgb3Igc3RhbGxzLiBKdXN0IHB1dCBsaW1p
dAo=
--001517511d3a30eaeb0494539342--
