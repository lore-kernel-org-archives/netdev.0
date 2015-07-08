From: Marian Corcodel <corcodel.marian@gmail.com>
Subject: Re: [net-next]Disable writting on reg config1 value is read-only
Date: Wed, 8 Jul 2015 23:07:56 +0300
Message-ID: <CAGg4U=F3u3pfOQ6zaeEmQxCE87ireKRLNkm4T-gp__Q7GbYaJA@mail.gmail.com>
References: <CAGg4U=GvLSYKU8nrNq9VmEyS1jZ9ZUtrVo-KMzR1Nd-ULVKMvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=089e01229aaae2d9b4051a62b1fc
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37840 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758144AbbGHUH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 16:07:57 -0400
Received: by igau2 with SMTP id u2so72583854iga.0
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 13:07:57 -0700 (PDT)
In-Reply-To: <CAGg4U=GvLSYKU8nrNq9VmEyS1jZ9ZUtrVo-KMzR1Nd-ULVKMvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--089e01229aaae2d9b4051a62b1fc
Content-Type: text/plain; charset=UTF-8

[net-next]resend Disable writting on reg config1 value is read-only
On rtl8101/8102 MEMMAP | IOMAP | VPD | PMEnable is enabled on default
and is read-only  and is not need to write on these.

2015-07-08 21:55 GMT+03:00 Marian Corcodel <corcodel.marian@gmail.com>:
> On rtl8101/8102 MEMMAP | IOMAP | VPD | PMEnable is enabled on default
> and is read-only  and is not need to write on these.

--089e01229aaae2d9b4051a62b1fc
Content-Type: text/x-patch; charset=US-ASCII; name="disable_writing_ro_reg.patch"
Content-Disposition: attachment; filename="disable_writing_ro_reg.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ibv7692v1

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L3JlYWx0ZWsvcjgxNjkuYyBiL2RyaXZl
cnMvbmV0L2V0aGVybmV0L3JlYWx0ZWsvcjgxNjkuYwppbmRleCAxYTU1MDU3Li5jMjg1MDI4IDEw
MDY0NAotLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9yZWFsdGVrL3I4MTY5LmMKKysrIGIvZHJp
dmVycy9uZXQvZXRoZXJuZXQvcmVhbHRlay9yODE2OS5jCkBAIC02NDE3LDcgKzY0MTcsNyBAQCBz
dGF0aWMgdm9pZCBydGxfaHdfc3RhcnRfODEwMmVfMihzdHJ1Y3QgcnRsODE2OV9wcml2YXRlICp0
cCkKIAogCXJ0bF90eF9wZXJmb3JtYW5jZV90d2VhayhwZGV2LCAweDUgPDwgTUFYX1JFQURfUkVR
VUVTVF9TSElGVCk7CiAKLQlSVExfVzgoQ29uZmlnMSwgTUVNTUFQIHwgSU9NQVAgfCBWUEQgfCBQ
TUVuYWJsZSk7CisJLy9SVExfVzgoQ29uZmlnMSwgTUVNTUFQIHwgSU9NQVAgfCBWUEQgfCBQTUVu
YWJsZSk7CiAJUlRMX1c4KENvbmZpZzMsIFJUTF9SOChDb25maWczKSAmIH5CZWFjb25fZW4pOwog
fQogCg==
--089e01229aaae2d9b4051a62b1fc--
