From: =?utf-8?B?Iklnb3IgTWFyYXZpxIci?= <igorm@etf.rs>
Subject: cls_rsvp.h fix
Date: Tue, 30 Aug 2011 11:33:15 +0200
Message-ID: <258b72c5817cd9a8437533d7908b546e.squirrel@kondor.etf.bg.ac.rs>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: multipart/mixed;boundary="----=_20110830113315_83600"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:59579 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362Ab1H3JdS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 05:33:18 -0400
Received: from localhost (avs2.etf.rs [147.91.14.173])
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id 3FD7260124
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 11:33:16 +0200 (CEST)
Received: from mx1.etf.bg.ac.rs ([147.91.14.169])
	by localhost (avs2.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id UaKUffaY+1Sd for <netdev@vger.kernel.org>;
	Tue, 30 Aug 2011 11:33:15 +0200 (CEST)
Received: from kondor.etf.bg.ac.rs (kondor.etf.bg.ac.rs [147.91.8.8])
	by mx1.etf.bg.ac.rs (Postfix) with ESMTP id 22E2B1200F1
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 11:33:14 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_20110830113315_83600
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable

File cls_rsvp.h was outdated. I'm sending you fix for this file.

Best regards
Igor Maravi=C4=87
Innovation Center of School of Electrical Engineering in Belgrade, Serbia

------=_20110830113315_83600
Content-Type: application/octet-stream; name="cls_rsvpFix"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="cls_rsvpFix"

LS0tIC91c3Ivc3JjL2xpbnV4LTIuNi4zOC44L25ldC9zY2hlZC9jbHNfcnN2cC5oCTIwMTEtMDYt
MDMgMDM6MzU6MTEuMDAwMDAwMDAwICswMjAwCisrKyAvdXNyL3NyYy9saW51eC0yLjYuMzguOC1t
cGxzL25ldC9zY2hlZC9jbHNfcnN2cC5oCTIwMTEtMDgtMzAgMTA6MDY6MDEuNjk1NDQwNjA1ICsw
MjAwCkBAIC00MjUsNyArNDI1LDcgQEAKIAlzdHJ1Y3QgcnN2cF9maWx0ZXIgKmYsICoqZnA7CiAJ
c3RydWN0IHJzdnBfc2Vzc2lvbiAqcywgKipzcDsKIAlzdHJ1Y3QgdGNfcnN2cF9waW5mbyAqcGlu
Zm8gPSBOVUxMOwotCXN0cnVjdCBubGF0dHIgKm9wdCA9IHRjYVtUQ0FfT1BUSU9OUy0xXTsKKwlz
dHJ1Y3QgbmxhdHRyICpvcHQgPSB0Y2FbVENBX09QVElPTlNdOwogCXN0cnVjdCBubGF0dHIgKnRi
W1RDQV9SU1ZQX01BWCArIDFdOwogCXN0cnVjdCB0Y2ZfZXh0cyBlOwogCXVuc2lnbmVkIGgxLCBo
MjsKQEAgLTQzOSw3ICs0MzksNyBAQAogCWlmIChlcnIgPCAwKQogCQlyZXR1cm4gZXJyOwogCi0J
ZXJyID0gdGNmX2V4dHNfdmFsaWRhdGUodHAsIHRiLCB0Y2FbVENBX1JBVEUtMV0sICZlLCAmcnN2
cF9leHRfbWFwKTsKKwllcnIgPSB0Y2ZfZXh0c192YWxpZGF0ZSh0cCwgdGIsIHRjYVtUQ0FfUkFU
RV0sICZlLCAmcnN2cF9leHRfbWFwKTsKIAlpZiAoZXJyIDwgMCkKIAkJcmV0dXJuIGVycjsKIApA
QCAtNDQ4LDggKzQ0OCw4IEBACiAKIAkJaWYgKGYtPmhhbmRsZSAhPSBoYW5kbGUgJiYgaGFuZGxl
KQogCQkJZ290byBlcnJvdXQyOwotCQlpZiAodGJbVENBX1JTVlBfQ0xBU1NJRC0xXSkgewotCQkJ
Zi0+cmVzLmNsYXNzaWQgPSBubGFfZ2V0X3UzMih0YltUQ0FfUlNWUF9DTEFTU0lELTFdKTsKKwkJ
aWYgKHRiW1RDQV9SU1ZQX0NMQVNTSURdKSB7CisJCQlmLT5yZXMuY2xhc3NpZCA9IG5sYV9nZXRf
dTMyKHRiW1RDQV9SU1ZQX0NMQVNTSURdKTsKIAkJCXRjZl9iaW5kX2ZpbHRlcih0cCwgJmYtPnJl
cywgYmFzZSk7CiAJCX0KIApAQCAtNDYxLDcgKzQ2MSw3IEBACiAJZXJyID0gLUVJTlZBTDsKIAlp
ZiAoaGFuZGxlKQogCQlnb3RvIGVycm91dDI7Ci0JaWYgKHRiW1RDQV9SU1ZQX0RTVC0xXSA9PSBO
VUxMKQorCWlmICh0YltUQ0FfUlNWUF9EU1RdID09IE5VTEwpCiAJCWdvdG8gZXJyb3V0MjsKIAog
CWVyciA9IC1FTk9CVUZTOwpAQCAtNDcwLDE5ICs0NzAsMTkgQEAKIAkJZ290byBlcnJvdXQyOwog
CiAJaDIgPSAxNjsKLQlpZiAodGJbVENBX1JTVlBfU1JDLTFdKSB7Ci0JCW1lbWNweShmLT5zcmMs
IG5sYV9kYXRhKHRiW1RDQV9SU1ZQX1NSQy0xXSksIHNpemVvZihmLT5zcmMpKTsKKwlpZiAodGJb
VENBX1JTVlBfU1JDXSkgeworCQltZW1jcHkoZi0+c3JjLCBubGFfZGF0YSh0YltUQ0FfUlNWUF9T
UkNdKSwgc2l6ZW9mKGYtPnNyYykpOwogCQloMiA9IGhhc2hfc3JjKGYtPnNyYyk7CiAJfQotCWlm
ICh0YltUQ0FfUlNWUF9QSU5GTy0xXSkgewotCQlwaW5mbyA9IG5sYV9kYXRhKHRiW1RDQV9SU1ZQ
X1BJTkZPLTFdKTsKKwlpZiAodGJbVENBX1JTVlBfUElORk9dKSB7CisJCXBpbmZvID0gbmxhX2Rh
dGEodGJbVENBX1JTVlBfUElORk9dKTsKIAkJZi0+c3BpID0gcGluZm8tPnNwaTsKIAkJZi0+dHVu
bmVsaGRyID0gcGluZm8tPnR1bm5lbGhkcjsKIAl9Ci0JaWYgKHRiW1RDQV9SU1ZQX0NMQVNTSUQt
MV0pCi0JCWYtPnJlcy5jbGFzc2lkID0gbmxhX2dldF91MzIodGJbVENBX1JTVlBfQ0xBU1NJRC0x
XSk7CisJaWYgKHRiW1RDQV9SU1ZQX0NMQVNTSURdKQorCQlmLT5yZXMuY2xhc3NpZCA9IG5sYV9n
ZXRfdTMyKHRiW1RDQV9SU1ZQX0NMQVNTSURdKTsKIAotCWRzdCA9IG5sYV9kYXRhKHRiW1RDQV9S
U1ZQX0RTVC0xXSk7CisJZHN0ID0gbmxhX2RhdGEodGJbVENBX1JTVlBfRFNUXSk7CiAJaDEgPSBo
YXNoX2RzdChkc3QsIHBpbmZvID8gcGluZm8tPnByb3RvY29sIDogMCwgcGluZm8gPyBwaW5mby0+
dHVubmVsaWQgOiAwKTsKIAogCWVyciA9IC1FTk9NRU07CkBAIC02NDIsNyArNjQyLDcgQEAKIH0K
IAogc3RhdGljIHN0cnVjdCB0Y2ZfcHJvdG9fb3BzIFJTVlBfT1BTID0gewotCS5uZXh0CQk9CU5V
TEwsCisJLy8ubmV4dAkJPQlOVUxMLAogCS5raW5kCQk9CVJTVlBfSUQsCiAJLmNsYXNzaWZ5CT0J
cnN2cF9jbGFzc2lmeSwKIAkuaW5pdAkJPQlyc3ZwX2luaXQsCg==
------=_20110830113315_83600--
