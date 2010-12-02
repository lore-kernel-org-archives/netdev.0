From: David Shwatrz <dshwatrz@gmail.com>
Subject: [PATCH net-next-2.6] [Resend] Fix a typo in datagram.c and sctp/socket.c.
Date: Thu, 2 Dec 2010 21:01:55 +0200
Message-ID: <AANLkTim+igD_3ob7d+_-yjTov_SDMf9GuPV8gzODCyk_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016364c72bb3112c30496720e6d
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53991 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757940Ab0LBTB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 14:01:56 -0500
Received: by wwa36 with SMTP id 36so9075101wwa.1
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 11:01:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016364c72bb3112c30496720e6d
Content-Type: text/plain; charset=ISO-8859-1

Hi,
This patch fixes a typo in net/core/datagram.c and in net/sctp/socket.c


Regards,
David Shwartz

Signed-off-by: David Shwartz <dshwatrz@gmail.com>

--0016364c72bb3112c30496720e6d
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gh80f59n0

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL2RhdGFncmFtLmMgYi9uZXQvY29yZS9kYXRhZ3JhbS5jCmlu
ZGV4IGNkMWUwMzkuLjE4YWMxMTIgMTAwNjQ0Ci0tLSBhL25ldC9jb3JlL2RhdGFncmFtLmMKKysr
IGIvbmV0L2NvcmUvZGF0YWdyYW0uYwpAQCAtMTc3LDcgKzE3Nyw3IEBAIHN0cnVjdCBza19idWZm
ICpfX3NrYl9yZWN2X2RhdGFncmFtKHN0cnVjdCBzb2NrICpzaywgdW5zaWduZWQgZmxhZ3MsCiAJ
CSAqIGludGVycnVwdCBsZXZlbCB3aWxsIHN1ZGRlbmx5IGVhdCB0aGUgcmVjZWl2ZV9xdWV1ZS4K
IAkJICoKIAkJICogTG9vayBhdCBjdXJyZW50IG5mcyBjbGllbnQgYnkgdGhlIHdheS4uLgotCQkg
KiBIb3dldmVyLCB0aGlzIGZ1bmN0aW9uIHdhcyBjb3JyZW50IGluIGFueSBjYXNlLiA4KQorCQkg
KiBIb3dldmVyLCB0aGlzIGZ1bmN0aW9uIHdhcyBjb3JyZWN0IGluIGFueSBjYXNlLiA4KQogCQkg
Ki8KIAkJdW5zaWduZWQgbG9uZyBjcHVfZmxhZ3M7CiAKZGlmZiAtLWdpdCBhL25ldC9zY3RwL3Nv
Y2tldC5jIGIvbmV0L3NjdHAvc29ja2V0LmMKaW5kZXggNmJkNTU0My4uODQyYzdmMyAxMDA2NDQK
LS0tIGEvbmV0L3NjdHAvc29ja2V0LmMKKysrIGIvbmV0L3NjdHAvc29ja2V0LmMKQEAgLTYwNDcs
NyArNjA0Nyw3IEBAIHN0YXRpYyBzdHJ1Y3Qgc2tfYnVmZiAqc2N0cF9za2JfcmVjdl9kYXRhZ3Jh
bShzdHJ1Y3Qgc29jayAqc2ssIGludCBmbGFncywKIAkJICogd2lsbCBzdWRkZW5seSBlYXQgdGhl
IHJlY2VpdmVfcXVldWUuCiAJCSAqCiAJCSAqICBMb29rIGF0IGN1cnJlbnQgbmZzIGNsaWVudCBi
eSB0aGUgd2F5Li4uCi0JCSAqICBIb3dldmVyLCB0aGlzIGZ1bmN0aW9uIHdhcyBjb3JyZW50IGlu
IGFueSBjYXNlLiA4KQorCQkgKiAgSG93ZXZlciwgdGhpcyBmdW5jdGlvbiB3YXMgY29ycmVjdCBp
biBhbnkgY2FzZS4gOCkKIAkJICovCiAJCWlmIChmbGFncyAmIE1TR19QRUVLKSB7CiAJCQlzcGlu
X2xvY2tfYmgoJnNrLT5za19yZWNlaXZlX3F1ZXVlLmxvY2spOwo=
--0016364c72bb3112c30496720e6d--
