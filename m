From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [RFC patch 1/1] large netlink dumps
Date: Sat, 15 Apr 2017 13:07:51 -0400
Message-ID: <e17f52a6-b2ad-6b39-a655-2e8779a5d192@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------D1D219853012C143045ACEF3"
Cc: Johannes Berg <johannes@sipsolutions.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:38192 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751364AbdDORHy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 13:07:54 -0400
Received: by mail-it0-f47.google.com with SMTP id e132so6785750ite.1
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2017 10:07:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------D1D219853012C143045ACEF3
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Eric,

How does attached look instead of the 32K?
I found it helps to let user space suggest something
larger.

cheers,
jamal

--------------D1D219853012C143045ACEF3
Content-Type: text/plain; charset=UTF-8;
 name="patch-netlink-large-dump"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="patch-netlink-large-dump"

ZGlmZiAtLWdpdCBhL25ldC9uZXRsaW5rL2FmX25ldGxpbmsuYyBiL25ldC9uZXRsaW5rL2Fm
X25ldGxpbmsuYwppbmRleCA3YjczYzdjLi5iYzk4MmVmIDEwMDY0NAotLS0gYS9uZXQvbmV0
bGluay9hZl9uZXRsaW5rLmMKKysrIGIvbmV0L25ldGxpbmsvYWZfbmV0bGluay5jCkBAIC0x
ODQ5LDcgKzE4NDksNyBAQCBzdGF0aWMgaW50IG5ldGxpbmtfcmVjdm1zZyhzdHJ1Y3Qgc29j
a2V0ICpzb2NrLCBzdHJ1Y3QgbXNnaGRyICptc2csIHNpemVfdCBsZW4sCiAJLyogUmVjb3Jk
IHRoZSBtYXggbGVuZ3RoIG9mIHJlY3Ztc2coKSBjYWxscyBmb3IgZnV0dXJlIGFsbG9jYXRp
b25zICovCiAJbmxrLT5tYXhfcmVjdm1zZ19sZW4gPSBtYXgobmxrLT5tYXhfcmVjdm1zZ19s
ZW4sIGxlbik7CiAJbmxrLT5tYXhfcmVjdm1zZ19sZW4gPSBtaW5fdChzaXplX3QsIG5say0+
bWF4X3JlY3Ztc2dfbGVuLAotCQkJCSAgICAgU0tCX1dJVEhfT1ZFUkhFQUQoMzI3NjgpKTsK
KwkJCQkgICAgIHNrLT5za19yY3ZidWYgLyA0KTsKIAogCWNvcGllZCA9IGRhdGFfc2tiLT5s
ZW47CiAJaWYgKGxlbiA8IGNvcGllZCkgewo=
--------------D1D219853012C143045ACEF3--
