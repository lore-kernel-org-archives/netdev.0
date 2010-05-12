From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next-2.6] [PPP] cleanup: remove pppoe_ioctl() declaration.
Date: Wed, 12 May 2010 08:37:36 +0300
Message-ID: <AANLkTinUFYCHp-9qw3bHIqolKrS0X33FjFmDsdS2XWec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e6db2b151a766e04865f0a94
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46593 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391Ab0ELFhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 01:37:38 -0400
Received: by wyb32 with SMTP id 32so501872wyb.19
        for <netdev@vger.kernel.org>; Tue, 11 May 2010 22:37:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016e6db2b151a766e04865f0a94
Content-Type: text/plain; charset=ISO-8859-1

Hi,
  - This patch removes pppoe_ioctl()  declaration in
drivers/net/pppoe.c as it is unneeded.


Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

--0016e6db2b151a766e04865f0a94
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g93pxcs40

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3BwcG9lLmMgYi9kcml2ZXJzL25ldC9wcHBvZS5jDQpv
bGQgbW9kZSAxMDA2NDQNCm5ldyBtb2RlIDEwMDc1NQ0KaW5kZXggOTlmMDMxYS4uNmZkODRlZA0K
LS0tIGEvZHJpdmVycy9uZXQvcHBwb2UuYw0KKysrIGIvZHJpdmVycy9uZXQvcHBwb2UuYw0KQEAg
LTg5LDcgKzg5LDYgQEANCiAjZGVmaW5lIFBQUE9FX0hBU0hfU0laRSAoMSA8PCBQUFBPRV9IQVNI
X0JJVFMpDQogI2RlZmluZSBQUFBPRV9IQVNIX01BU0sJKFBQUE9FX0hBU0hfU0laRSAtIDEpDQog
DQotc3RhdGljIGludCBwcHBvZV9pb2N0bChzdHJ1Y3Qgc29ja2V0ICpzb2NrLCB1bnNpZ25lZCBp
bnQgY21kLCB1bnNpZ25lZCBsb25nIGFyZyk7DQogc3RhdGljIGludCBwcHBvZV94bWl0KHN0cnVj
dCBwcHBfY2hhbm5lbCAqY2hhbiwgc3RydWN0IHNrX2J1ZmYgKnNrYik7DQogc3RhdGljIGludCBf
X3BwcG9lX3htaXQoc3RydWN0IHNvY2sgKnNrLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKTsNCiANCg==
--0016e6db2b151a766e04865f0a94--
