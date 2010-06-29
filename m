From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next-2.6] xfrm: remove export of xfrm4_rcv_encap.
Date: Tue, 29 Jun 2010 08:05:55 +0300
Message-ID: <AANLkTimIJ_vhe7wwCqTrfjj4HUdrbpyrlAwnQGrtAiOk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e65b61c029cd3a048a24315a
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51833 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab0F2FF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 01:05:58 -0400
Received: by wyb38 with SMTP id 38so2380336wyb.19
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 22:05:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016e65b61c029cd3a048a24315a
Content-Type: text/plain; charset=ISO-8859-1

Hi,
 The patch removes EXPORT_SYMBOL of xfrm4_rcv_encap() method
 as it is unneeded.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

--0016e65b61c029cd3a048a24315a
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gb09y25c0

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L3hmcm00X2lucHV0LmMgYi9uZXQvaXB2NC94ZnJtNF9pbnB1
dC5jDQppbmRleCBhZDhmYmI4Li5kODUzMzZjIDEwMDY0NA0KLS0tIGEvbmV0L2lwdjQveGZybTRf
aW5wdXQuYw0KKysrIGIvbmV0L2lwdjQveGZybTRfaW5wdXQuYw0KQEAgLTQ0LDcgKzQ0LDYgQEAg
aW50IHhmcm00X3Jjdl9lbmNhcChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBpbnQgbmV4dGhkciwgX19i
ZTMyIHNwaSwNCiAJWEZSTV9TUElfU0tCX0NCKHNrYiktPmRhZGRyb2ZmID0gb2Zmc2V0b2Yoc3Ry
dWN0IGlwaGRyLCBkYWRkcik7DQogCXJldHVybiB4ZnJtX2lucHV0KHNrYiwgbmV4dGhkciwgc3Bp
LCBlbmNhcF90eXBlKTsNCiB9DQotRVhQT1JUX1NZTUJPTCh4ZnJtNF9yY3ZfZW5jYXApOw0KIA0K
IGludCB4ZnJtNF90cmFuc3BvcnRfZmluaXNoKHN0cnVjdCBza19idWZmICpza2IsIGludCBhc3lu
YykNCiB7DQo=
--0016e65b61c029cd3a048a24315a--
