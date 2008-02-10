From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH] [IPV6] Minor cleanup: remove unused method declaration (net/ndisc.h).
Date: Sun, 10 Feb 2008 18:40:13 +0200
Message-ID: <eb3ff54b0802100840g52a5eb68y8140d3e2e2d94c26@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_17786_19933953.1202661613241"
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:9025 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbYBJQkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 11:40:14 -0500
Received: by fg-out-1718.google.com with SMTP id e21so3516405fga.17
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2008 08:40:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_17786_19933953.1202661613241
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

This patch removes unused declaration of dflt_rt_lookup() method in
include/net/ndisc.h


Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_17786_19933953.1202661613241
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fchtloj50
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L25kaXNjLmggYi9pbmNsdWRlL25ldC9uZGlzYy5oCmlu
ZGV4IDY2ODRmN2UuLjU5YjcwNjIgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbmV0L25kaXNjLmgKKysr
IGIvaW5jbHVkZS9uZXQvbmRpc2MuaApAQCAtMTAzLDcgKzEwMyw2IEBAIGV4dGVybiB2b2lkCQkJ
bmRpc2Nfc2VuZF9yZWRpcmVjdChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAogZXh0ZXJuIGludAkJCW5k
aXNjX21jX21hcChzdHJ1Y3QgaW42X2FkZHIgKmFkZHIsIGNoYXIgKmJ1Ziwgc3RydWN0IG5ldF9k
ZXZpY2UgKmRldiwgaW50IGRpcik7CiAKIAotc3RydWN0IHJ0Nl9pbmZvICoJCWRmbHRfcnRfbG9v
a3VwKHZvaWQpOwogCiAvKgogICoJSUdNUAo=
------=_Part_17786_19933953.1202661613241--
