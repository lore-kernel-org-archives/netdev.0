From: "Mark Ryden" <markryde@gmail.com>
Subject: [PATCH] remove not used code: target hw address (tha) definition and assignment in arp_process().
Date: Thu, 20 Dec 2007 09:29:47 +0200
Message-ID: <dac45060712192329v48bcd3td4f16f83ea13ba9e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_20696_11251323.1198135787872"
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:27265 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbXLTH3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 02:29:48 -0500
Received: by wa-out-1112.google.com with SMTP id v27so5064124wah.23
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 23:29:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_20696_11251323.1198135787872
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,
  In arp_process() (net/ipv4/arp.c), there is unused code: definition
and assignment of tha (target hw address ).


Signed-off-by:
markryde@gmail.com

------=_Part_20696_11251323.1198135787872
Content-Type: text/x-patch; name=patchGit.diff
Content-Transfer-Encoding: base64
X-Attachment-Id: f_faez1fxa0
Content-Disposition: attachment; filename=patchGit.diff

ZGlmZiAtLWdpdCBhL2EvbmV0L2lwdjQvYXJwLmMgYi9iL25ldC9pcHY0L2FycC5jCmluZGV4IDE0
ZGVjOTIuLjZmMjZjZmUgMTAwNjQ0Ci0tLSBhL2EvbmV0L2lwdjQvYXJwLmMKKysrIGIvYi9uZXQv
aXB2NC9hcnAuYwpAQCAtNzA2LDcgKzcwNiw3IEBAIHN0YXRpYyBpbnQgYXJwX3Byb2Nlc3Moc3Ry
dWN0IHNrX2J1ZmYgKnNrYikKIAlzdHJ1Y3QgYXJwaGRyICphcnA7CiAJdW5zaWduZWQgY2hhciAq
YXJwX3B0cjsKIAlzdHJ1Y3QgcnRhYmxlICpydDsKLQl1bnNpZ25lZCBjaGFyICpzaGEsICp0aGE7
CisJdW5zaWduZWQgY2hhciAqc2hhOwogCV9fYmUzMiBzaXAsIHRpcDsKIAl1MTYgZGV2X3R5cGUg
PSBkZXYtPnR5cGU7CiAJaW50IGFkZHJfdHlwZTsKQEAgLTc3MSw3ICs3NzEsNiBAQCBzdGF0aWMg
aW50IGFycF9wcm9jZXNzKHN0cnVjdCBza19idWZmICpza2IpCiAJYXJwX3B0ciArPSBkZXYtPmFk
ZHJfbGVuOwogCW1lbWNweSgmc2lwLCBhcnBfcHRyLCA0KTsKIAlhcnBfcHRyICs9IDQ7Ci0JdGhh
CT0gYXJwX3B0cjsKIAlhcnBfcHRyICs9IGRldi0+YWRkcl9sZW47CiAJbWVtY3B5KCZ0aXAsIGFy
cF9wdHIsIDQpOwogLyoK
------=_Part_20696_11251323.1198135787872--
