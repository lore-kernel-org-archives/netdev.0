From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next-2.6] net: remove unused icmp_ioctl() definition.
Date: Thu, 29 Mar 2012 20:49:01 +0200
Message-ID: <CAHLOa7RZFQHLtsYE2VeS7Fmhcr+O9guEFYYVoGTPJQos48Eo1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b10cac164168b04bc662d28
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34881 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932349Ab2C2StB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 14:49:01 -0400
Received: by pbcun15 with SMTP id un15so480233pbc.19
        for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 11:49:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7b10cac164168b04bc662d28
Content-Type: text/plain; charset=ISO-8859-1

Hi,

 The patch removes unused icmp_ioctl() method definition in include/net/icmp.h.

Signed-off-by: Rami Rosen <ramirose@gmail.com>

--047d7b10cac164168b04bc662d28
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h0e5p5ra0

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2ljbXAuaCBiL2luY2x1ZGUvbmV0L2ljbXAuaAppbmRl
eCA3NWQ2MTU2Li5jZTcwYTU4IDEwMDY0NAotLS0gYS9pbmNsdWRlL25ldC9pY21wLmgKKysrIGIv
aW5jbHVkZS9uZXQvaWNtcC5oCkBAIC00MSw3ICs0MSw2IEBAIHN0cnVjdCBuZXQ7CiAKIGV4dGVy
biB2b2lkCWljbXBfc2VuZChzdHJ1Y3Qgc2tfYnVmZiAqc2tiX2luLCAgaW50IHR5cGUsIGludCBj
b2RlLCBfX2JlMzIgaW5mbyk7CiBleHRlcm4gaW50CWljbXBfcmN2KHN0cnVjdCBza19idWZmICpz
a2IpOwotZXh0ZXJuIGludAlpY21wX2lvY3RsKHN0cnVjdCBzb2NrICpzaywgaW50IGNtZCwgdW5z
aWduZWQgbG9uZyBhcmcpOwogZXh0ZXJuIGludAlpY21wX2luaXQodm9pZCk7CiBleHRlcm4gdm9p
ZAlpY21wX291dF9jb3VudChzdHJ1Y3QgbmV0ICpuZXQsIHVuc2lnbmVkIGNoYXIgdHlwZSk7CiAK
--047d7b10cac164168b04bc662d28--
