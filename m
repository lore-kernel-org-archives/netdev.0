From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next-2.6] [PPPOE] cleanup: remove pppoe_xmit()
	declaration.
Date: Wed, 9 Jun 2010 08:07:56 +0300
Message-ID: <AANLkTim_Jg51_xyfeLD3m4i88TGv8B2SRHFZ-H31w1YK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e6da2eb68de8b8048891e32b
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:57198 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385Ab0FIFH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 01:07:57 -0400
Received: by wwb28 with SMTP id 28so1068573wwb.19
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 22:07:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016e6da2eb68de8b8048891e32b
Content-Type: text/plain; charset=ISO-8859-1

Hi,
There is no need for pppoe_xmit() forward declaration in
drivers/net/pppoe.c. This patch removes this  pppoe_xmit() declaration.

Regards,
Rami Rosen



Signed-off-by: Rami Rosen <ramirose@gmail.com>

--0016e6da2eb68de8b8048891e32b
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ga7p6wk70

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3BwcG9lLmMgYi9kcml2ZXJzL25ldC9wcHBvZS5jDQpp
bmRleCA3ZWJiOGU4Li4zNDRlZjMzIDEwMDY0NA0KLS0tIGEvZHJpdmVycy9uZXQvcHBwb2UuYw0K
KysrIGIvZHJpdmVycy9uZXQvcHBwb2UuYw0KQEAgLTg5LDcgKzg5LDYgQEANCiAjZGVmaW5lIFBQ
UE9FX0hBU0hfU0laRSAoMSA8PCBQUFBPRV9IQVNIX0JJVFMpDQogI2RlZmluZSBQUFBPRV9IQVNI
X01BU0sJKFBQUE9FX0hBU0hfU0laRSAtIDEpDQogDQotc3RhdGljIGludCBwcHBvZV94bWl0KHN0
cnVjdCBwcHBfY2hhbm5lbCAqY2hhbiwgc3RydWN0IHNrX2J1ZmYgKnNrYik7DQogc3RhdGljIGlu
dCBfX3BwcG9lX3htaXQoc3RydWN0IHNvY2sgKnNrLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKTsNCiAN
CiBzdGF0aWMgY29uc3Qgc3RydWN0IHByb3RvX29wcyBwcHBvZV9vcHM7DQo=
--0016e6da2eb68de8b8048891e32b--
