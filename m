From: matthieu castet <castet.matthieu@free.fr>
Subject: [PATH] Allow mtu bigger than 1500 for ieee80211
Date: Thu, 28 Sep 2006 19:57:25 +0200
Message-ID: <451C0D05.4050705@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080800010005000002020505"
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g19.free.fr ([212.27.42.29]:59532 "EHLO smtp3-g19.free.fr")
	by vger.kernel.org with ESMTP id S1751962AbWI1R53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 13:57:29 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080800010005000002020505
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi

this patch allow to set the mtu between 1500 and 2304 (max octets in an 
MSDU) for devices using ieee80211 linux stack.

Signed-off-by: Matthieu CASTET <castet.matthieu@free.fr>

--------------080800010005000002020505
Content-Type: text/plain;
 name="ieee80211mtu"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="ieee80211mtu"

SW5kZXg6IGxpbnV4L25ldC9pZWVlODAyMTEvaWVlZTgwMjExX21vZHVsZS5jCj09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT0KLS0tIGxpbnV4Lm9yaWcvbmV0L2llZWU4MDIxMS9pZWVlODAyMTFfbW9kdWxlLmMJ
MjAwNi0wOS0yNiAxOToyNzoyNi4wMDAwMDAwMDAgKzAyMDAKKysrIGxpbnV4L25ldC9pZWVl
ODAyMTEvaWVlZTgwMjExX21vZHVsZS5jCTIwMDYtMDktMjggMTk6NTA6NTMuMDAwMDAwMDAw
ICswMjAwCkBAIC0xMTgsNiArMTE4LDE0IEBACiAJCQkgICAgICAmaWVlZS0+bmV0d29ya19m
cmVlX2xpc3QpOwogfQogCitzdGF0aWMgaW50IGllZWU4MDIxMV9jaGFuZ2VfbXR1KHN0cnVj
dCBuZXRfZGV2aWNlICpkZXYsIGludCBuZXdfbXR1KQoreworCWlmICgobmV3X210dSA8IDY4
KSB8fCAobmV3X210dSA+IElFRUU4MDIxMV9EQVRBX0xFTikpCisJCXJldHVybiAtRUlOVkFM
OworCWRldi0+bXR1ID0gbmV3X210dTsKKwlyZXR1cm4gMDsKK30KKwogc3RydWN0IG5ldF9k
ZXZpY2UgKmFsbG9jX2llZWU4MDIxMShpbnQgc2l6ZW9mX3ByaXYpCiB7CiAJc3RydWN0IGll
ZWU4MDIxMV9kZXZpY2UgKmllZWU7CkBAIC0xMzMsNiArMTQxLDcgQEAKIAl9CiAJaWVlZSA9
IG5ldGRldl9wcml2KGRldik7CiAJZGV2LT5oYXJkX3N0YXJ0X3htaXQgPSBpZWVlODAyMTFf
eG1pdDsKKwlkZXYtPmNoYW5nZV9tdHUgPSBpZWVlODAyMTFfY2hhbmdlX210dTsKIAogCWll
ZWUtPmRldiA9IGRldjsKIAo=
--------------080800010005000002020505--
