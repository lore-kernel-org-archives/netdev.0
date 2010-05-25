From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next-2.6] [PPP] cleanup: remove MIN_FRAG_SIZE definition.
Date: Tue, 25 May 2010 23:00:46 +0300
Message-ID: <AANLkTilPBlMQJsKaY8Ksa2GzQ1by9H8HMyXZCDoHcNPE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e6d96d90fc9d5b0487709c97
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50357 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934006Ab0EYUAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 16:00:48 -0400
Received: by wyb29 with SMTP id 29so2685379wyb.19
        for <netdev@vger.kernel.org>; Tue, 25 May 2010 13:00:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016e6d96d90fc9d5b0487709c97
Content-Type: text/plain; charset=ISO-8859-1

Hi,
 - This patch removes MIN_FRAG_SIZE definition in
drivers/net/ppp_generic.c as it is unneeded.


Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

--0016e6d96d90fc9d5b0487709c97
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g9n5etiv0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3BwcF9nZW5lcmljLmMgYi9kcml2ZXJzL25ldC9wcHBf
Z2VuZXJpYy5jCmluZGV4IDM1ZjE5NTMuLmEyMTQ4MzUgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0
L3BwcF9nZW5lcmljLmMKKysrIGIvZHJpdmVycy9uZXQvcHBwX2dlbmVyaWMuYwpAQCAtNjksNyAr
NjksNiBAQAogCiAjZGVmaW5lIE1QSERSTEVOCTYJLyogbXVsdGlsaW5rIHByb3RvY29sIGhlYWRl
ciBsZW5ndGggKi8KICNkZWZpbmUgTVBIRFJMRU5fU1NOCTQJLyogZGl0dG8gd2l0aCBzaG9ydCBz
ZXF1ZW5jZSBudW1iZXJzICovCi0jZGVmaW5lIE1JTl9GUkFHX1NJWkUJNjQKIAogLyoKICAqIEFu
IGluc3RhbmNlIG9mIC9kZXYvcHBwIGNhbiBiZSBhc3NvY2lhdGVkIHdpdGggZWl0aGVyIGEgcHBw
Cg==
--0016e6d96d90fc9d5b0487709c97--
