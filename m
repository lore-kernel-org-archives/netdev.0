From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.26] [IPV6] Remove three method declarations in include/net/ndisc.h.
Date: Tue, 1 Apr 2008 14:33:54 +0300
Message-ID: <eb3ff54b0804010433v67f0ea60w4681b3a3400c3484@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_13238_10317193.1207049634727"
Cc: linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:60418 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756962AbYDALd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 07:33:56 -0400
Received: by fg-out-1718.google.com with SMTP id l27so2356603fgb.17
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2008 04:33:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_13238_10317193.1207049634727
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
This patch removes two unused method declarations in include/net/ndisc.h:
ndisc_forwarding_on(void) and  ndisc_forwarding_off(void);
Also igmp6_cleanup(void) appears twice in this header, so one
igmp6_cleanup(void)
declaration is removed.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_13238_10317193.1207049634727
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_feicv8ac0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L25kaXNjLmggYi9pbmNsdWRlL25ldC9uZGlzYy5oCmlu
ZGV4IDVhZWRmMzIuLjBjMzJkNDMgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbmV0L25kaXNjLmgKKysr
IGIvaW5jbHVkZS9uZXQvbmRpc2MuaApAQCAtOTMsOSArOTMsNiBAQCBleHRlcm4gdm9pZAkJCW5k
aXNjX3NlbmRfcnMoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwKIAkJCQkJICAgICAgc3RydWN0IGlu
Nl9hZGRyICpzYWRkciwKIAkJCQkJICAgICAgc3RydWN0IGluNl9hZGRyICpkYWRkcik7CiAKLWV4
dGVybiB2b2lkCQkJbmRpc2NfZm9yd2FyZGluZ19vbih2b2lkKTsKLWV4dGVybiB2b2lkCQkJbmRp
c2NfZm9yd2FyZGluZ19vZmYodm9pZCk7Ci0KIGV4dGVybiB2b2lkCQkJbmRpc2Nfc2VuZF9yZWRp
cmVjdChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAogCQkJCQkJICAgIHN0cnVjdCBuZWlnaGJvdXIgKm5l
aWdoLAogCQkJCQkJICAgIHN0cnVjdCBpbjZfYWRkciAqdGFyZ2V0KTsKQEAgLTExNSw3ICsxMTIs
NiBAQCBleHRlcm4gaW50CQkJaWdtcDZfZXZlbnRfcXVlcnkoc3RydWN0IHNrX2J1ZmYgKnNrYik7
CiAKIGV4dGVybiBpbnQJCQlpZ21wNl9ldmVudF9yZXBvcnQoc3RydWN0IHNrX2J1ZmYgKnNrYik7
CiAKLWV4dGVybiB2b2lkCQkJaWdtcDZfY2xlYW51cCh2b2lkKTsKIAogI2lmZGVmIENPTkZJR19T
WVNDVEwKIGV4dGVybiBpbnQgCQkJbmRpc2NfaWZpbmZvX3N5c2N0bF9jaGFuZ2Uoc3RydWN0IGN0
bF90YWJsZSAqY3RsLAo=
------=_Part_13238_10317193.1207049634727--
