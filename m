From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next-2.6] RPS: enables setting CONFIG_RPS config option.
Date: Tue, 23 Nov 2010 22:10:37 +0200
Message-ID: <AANLkTikLP0_Xphc7ECwF7yuffqU0dmw1QWdpc36dfMAT@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=00163628430a50dd2d0495bdf782
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:44421 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943Ab0KWUKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 15:10:38 -0500
Received: by qyk12 with SMTP id 12so2759643qyk.19
        for <netdev@vger.kernel.org>; Tue, 23 Nov 2010 12:10:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--00163628430a50dd2d0495bdf782
Content-Type: text/plain; charset=ISO-8859-1

Hi,
 The patch enables setting CONFIG_RPS config option for
 Receive packet steering (net/Kconfig.).

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

--00163628430a50dd2d0495bdf782
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ggv7ocnj0

ZGlmZiAtLWdpdCBhL25ldC9LY29uZmlnIGIvbmV0L0tjb25maWcKaW5kZXggNTVmZDgyZS4uZDE1
YzNjYiAxMDA2NDQKLS0tIGEvbmV0L0tjb25maWcKKysrIGIvbmV0L0tjb25maWcKQEAgLTIxNiw5
ICsyMTYsMTIgQEAgc291cmNlICJuZXQvZGNiL0tjb25maWciCiBzb3VyY2UgIm5ldC9kbnNfcmVz
b2x2ZXIvS2NvbmZpZyIKIAogY29uZmlnIFJQUwotCWJvb2xlYW4KKwlib29sICJSZWNlaXZlIHBh
Y2tldCBzdGVlcmluZyAoUlBTKSIKIAlkZXBlbmRzIG9uIFNNUCAmJiBTWVNGUyAmJiBVU0VfR0VO
RVJJQ19TTVBfSEVMUEVSUwogCWRlZmF1bHQgeQorCS0tLWhlbHAtLS0KKwkgIFN1cHBvcnQgZm9y
IFJlY2VpdmUgcGFja2V0IHN0ZWVyaW5nIChSUFMpLCB3aGljaCBkaXN0cmlidXRlcyB0aGUgd29y
ayBvZgorCQlvdXRnb2luZyBkYXRhIGFjcm9zcyBDUFVzLgogCiBtZW51ICJOZXR3b3JrIHRlc3Rp
bmciCiAK
--00163628430a50dd2d0495bdf782--
