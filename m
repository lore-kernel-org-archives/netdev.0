From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next-2.6] cleanup: remove unused member in scm_cookie.
Date: Thu, 25 Jun 2009 17:42:19 +0300
Message-ID: <eb3ff54b0906250742r1507927ai1755e514506bad0d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0015174c1d901f9bf2046d2d3b92
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:63567 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbZFYOmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 10:42:17 -0400
Received: by ewy6 with SMTP id 6so2316872ewy.37
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2009 07:42:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0015174c1d901f9bf2046d2d3b92
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,
This patch removes an unused member (seq) scm_cookie; besides initialized
to 0 in the header file, it is not used.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

--0015174c1d901f9bf2046d2d3b92
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fwdl1cu00

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L3NjbS5oIGIvaW5jbHVkZS9uZXQvc2NtLmgKaW5kZXgg
ZjQ1YmI2ZS4uY2Y0OGM4MCAxMDA2NDQKLS0tIGEvaW5jbHVkZS9uZXQvc2NtLmgKKysrIGIvaW5j
bHVkZS9uZXQvc2NtLmgKQEAgLTI2LDcgKzI2LDYgQEAgc3RydWN0IHNjbV9jb29raWUKICNpZmRl
ZiBDT05GSUdfU0VDVVJJVFlfTkVUV09SSwogCXUzMgkJCXNlY2lkOwkJLyogUGFzc2VkIHNlY3Vy
aXR5IElEIAkqLwogI2VuZGlmCi0JdW5zaWduZWQgbG9uZwkJc2VxOwkJLyogQ29ubmVjdGlvbiBz
ZXFubwkqLwogfTsKIAogZXh0ZXJuIHZvaWQgc2NtX2RldGFjaF9mZHMoc3RydWN0IG1zZ2hkciAq
bXNnLCBzdHJ1Y3Qgc2NtX2Nvb2tpZSAqc2NtKTsKQEAgLTU5LDcgKzU4LDYgQEAgc3RhdGljIF9f
aW5saW5lX18gaW50IHNjbV9zZW5kKHN0cnVjdCBzb2NrZXQgKnNvY2ssIHN0cnVjdCBtc2doZHIg
Km1zZywKIAlzY20tPmNyZWRzLmdpZCA9IGN1cnJlbnRfZ2lkKCk7CiAJc2NtLT5jcmVkcy5waWQg
PSB0YXNrX3RnaWRfdm5yKHApOwogCXNjbS0+ZnAgPSBOVUxMOwotCXNjbS0+c2VxID0gMDsKIAl1
bml4X2dldF9wZWVyc2VjX2RncmFtKHNvY2ssIHNjbSk7CiAJaWYgKG1zZy0+bXNnX2NvbnRyb2xs
ZW4gPD0gMCkKIAkJcmV0dXJuIDA7Cg==
--0015174c1d901f9bf2046d2d3b92--
