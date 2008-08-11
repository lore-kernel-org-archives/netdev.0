From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6 1/2] ipv6: ip6_route.h cleanup.
Date: Mon, 11 Aug 2008 09:08:32 +0300
Message-ID: <eb3ff54b0808102308u3b83dec3xf868cc4fe43677@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_69556_9984694.1218434912366"
Cc: netdev@vger.kernel.org,
	"=?BIG5?B?WU9TSElGVUpJIEhpZGVha2kgLyCmTsPDrV6p+g==?="
	<yoshfuji@linux-ipv6.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:44825 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbYHKGIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 02:08:32 -0400
Received: by wf-out-1314.google.com with SMTP id 27so3694246wfd.4
        for <netdev@vger.kernel.org>; Sun, 10 Aug 2008 23:08:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_69556_9984694.1218434912366
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
  This patch removes rt6_lock declaration from include/net/ip6_route.h
	as it is unused.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_69556_9984694.1218434912366
Content-Type: text/x-patch; name=0012-remove_rt6_lock.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fjqojsyv0
Content-Disposition: attachment; filename=0012-remove_rt6_lock.patch

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2lwNl9yb3V0ZS5oIGIvaW5jbHVkZS9uZXQvaXA2X3Jv
dXRlLmgKaW5kZXggMmY4YjNjMC4uNDlkMDg1NiAxMDA2NDQKLS0tIGEvaW5jbHVkZS9uZXQvaXA2
X3JvdXRlLmgKKysrIGIvaW5jbHVkZS9uZXQvaXA2X3JvdXRlLmgKQEAgLTExOCw3ICsxMTgsNiBA
QCBleHRlcm4gaW50IHJ0Nl9kdW1wX3JvdXRlKHN0cnVjdCBydDZfaW5mbyAqcnQsIHZvaWQgKnBf
YXJnKTsKIGV4dGVybiB2b2lkIHJ0Nl9pZmRvd24oc3RydWN0IG5ldCAqbmV0LCBzdHJ1Y3QgbmV0
X2RldmljZSAqZGV2KTsKIGV4dGVybiB2b2lkIHJ0Nl9tdHVfY2hhbmdlKHN0cnVjdCBuZXRfZGV2
aWNlICpkZXYsIHVuc2lnbmVkIG10dSk7CiAKLWV4dGVybiByd2xvY2tfdCBydDZfbG9jazsKIAog
LyoKICAqCVN0b3JlIGEgZGVzdGluYXRpb24gY2FjaGUgZW50cnkgaW4gYSBzb2NrZXQKCg==
------=_Part_69556_9984694.1218434912366--
