From: David Shwatrz <dshwatrz@gmail.com>
Subject: [PATCH net-next-2.6] XFRM: remove unused member in xfrm_encap_tmpl.
Date: Sat, 27 Nov 2010 19:24:57 +0200
Message-ID: <AANLkTiknTcWaRykGOTbw6JpFZN-ePnRXd3iWz86yYHKi@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e6dbe8023a5e6b04960c1e2e
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35363 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818Ab0K0RY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Nov 2010 12:24:59 -0500
Received: by wwa36 with SMTP id 36so3180310wwa.1
        for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 09:24:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016e6dbe8023a5e6b04960c1e2e
Content-Type: text/plain; charset=ISO-8859-1

Hi,
 The patch removes unused member in xfrm_encap_tmpl.

Regards,
David Shwartz


Signed-off-by: David Shwartz <dshwatrz@gmail.com>

--0016e6dbe8023a5e6b04960c1e2e
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gh0rqf5s0

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgveGZybS5oIGIvaW5jbHVkZS9saW51eC94ZnJtLmgK
aW5kZXggYjk3MWUzOC4uNzMxMjcwNyAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC94ZnJtLmgK
KysrIGIvaW5jbHVkZS9saW51eC94ZnJtLmgKQEAgLTIzNSw3ICsyMzUsNiBAQCBzdHJ1Y3QgeGZy
bV9lbmNhcF90bXBsIHsKIAlfX3UxNgkJZW5jYXBfdHlwZTsKIAlfX2JlMTYJCWVuY2FwX3Nwb3J0
OwogCV9fYmUxNgkJZW5jYXBfZHBvcnQ7Ci0JeGZybV9hZGRyZXNzX3QJZW5jYXBfb2E7CiB9Owog
CiAvKiBBRVZFTlQgZmxhZ3MgICovCmRpZmYgLS1naXQgYS9uZXQva2V5L2FmX2tleS5jIGIvbmV0
L2tleS9hZl9rZXkuYwppbmRleCBkODdjMjJkLi40ODUxZGViIDEwMDY0NAotLS0gYS9uZXQva2V5
L2FmX2tleS5jCisrKyBiL25ldC9rZXkvYWZfa2V5LmMKQEAgLTEyNDUsNyArMTI0NSw2IEBAIHN0
YXRpYyBzdHJ1Y3QgeGZybV9zdGF0ZSAqIHBma2V5X21zZzJ4ZnJtX3N0YXRlKHN0cnVjdCBuZXQg
Km5ldCwKIAkJCQlleHRfaGRyc1tTQURCX1hfRVhUX05BVF9UX0RQT1JULTFdOwogCQkJbmF0dC0+
ZW5jYXBfZHBvcnQgPSBuX3BvcnQtPnNhZGJfeF9uYXRfdF9wb3J0X3BvcnQ7CiAJCX0KLQkJbWVt
c2V0KCZuYXR0LT5lbmNhcF9vYSwgMCwgc2l6ZW9mKG5hdHQtPmVuY2FwX29hKSk7CiAJfQogCiAJ
ZXJyID0geGZybV9pbml0X3N0YXRlKHgpOwo=
--0016e6dbe8023a5e6b04960c1e2e--
