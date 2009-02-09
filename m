From: frederic rodo <fred.rodo@gmail.com>
Subject: [PATCH 2/2] MX27 FEC add mii_bus
Date: Mon, 9 Feb 2009 11:28:15 +0100
Message-ID: <d99e615c0902090228q19f84e78qa8b2d2ccf6a6fa34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0015174c3d1611c0ad046279d4e8
Cc: Sascha Hauer <s.hauer@pengutronix.de>, gerg@snapgear.com,
	netdev@vger.kernel.org
To: linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:39882 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752943AbZBIK2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 05:28:17 -0500
Received: by ewy14 with SMTP id 14so2443052ewy.13
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2009 02:28:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0015174c3d1611c0ad046279d4e8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit



--0015174c3d1611c0ad046279d4e8
Content-Type: text/x-patch; charset=US-ASCII; name="mxc_add_mxc_eth_platform.patch"
Content-Disposition: attachment; filename="mxc_add_mxc_eth_platform.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fqz088m90

U2lnbmVkLW9mZi1ieTogRnJlZGVyaWMgUm9kbyA8ZnJlZC5yb2RvQGdtYWlsLmNvbT4KZGlmZiAt
LWdpdCBhL2luY2x1ZGUvbGludXgvZmVjLmggYi9pbmNsdWRlL2xpbnV4L2ZlYy5oCm5ldyBmaWxl
IG1vZGUgMTAwNjQ0CmluZGV4IDAwMDAwMDAuLmQxMzBiY2YKLS0tIC9kZXYvbnVsbAorKysgYi9p
bmNsdWRlL2xpbnV4L2ZlYy5oCkBAIC0wLDAgKzEsMjYgQEAKKy8qCisgKiBDb3B5cmlnaHQgMjAw
OSBGcmVkZXJpYyBSb2RvLCBmcmVkLnJvZG9AZ21haWwuY29tCisgKgorICogVGhpcyBwcm9ncmFt
IGlzIGZyZWUgc29mdHdhcmU7IHlvdSBjYW4gcmVkaXN0cmlidXRlIGl0IGFuZC9vcgorICogbW9k
aWZ5IGl0IHVuZGVyIHRoZSB0ZXJtcyBvZiB0aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UK
KyAqIGFzIHB1Ymxpc2hlZCBieSB0aGUgRnJlZSBTb2Z0d2FyZSBGb3VuZGF0aW9uOyBlaXRoZXIg
dmVyc2lvbiAyCisgKiBvZiB0aGUgTGljZW5zZSwgb3IgKGF0IHlvdXIgb3B0aW9uKSBhbnkgbGF0
ZXIgdmVyc2lvbi4KKyAqIFRoaXMgcHJvZ3JhbSBpcyBkaXN0cmlidXRlZCBpbiB0aGUgaG9wZSB0
aGF0IGl0IHdpbGwgYmUgdXNlZnVsLAorICogYnV0IFdJVEhPVVQgQU5ZIFdBUlJBTlRZOyB3aXRo
b3V0IGV2ZW4gdGhlIGltcGxpZWQgd2FycmFudHkgb2YKKyAqIE1FUkNIQU5UQUJJTElUWSBvciBG
SVRORVNTIEZPUiBBIFBBUlRJQ1VMQVIgUFVSUE9TRS4gIFNlZSB0aGUKKyAqIEdOVSBHZW5lcmFs
IFB1YmxpYyBMaWNlbnNlIGZvciBtb3JlIGRldGFpbHMuCisgKgorICogWW91IHNob3VsZCBoYXZl
IHJlY2VpdmVkIGEgY29weSBvZiB0aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UKKyAqIGFs
b25nIHdpdGggdGhpcyBwcm9ncmFtOyBpZiBub3QsIHdyaXRlIHRvIHRoZSBGcmVlIFNvZnR3YXJl
CisgKiBGb3VuZGF0aW9uLCBJbmMuLCA1MSBGcmFua2xpbiBTdHJlZXQsIEZpZnRoIEZsb29yLCBC
b3N0b24sCisgKiBNQSAwMjExMC0xMzAxLCBVU0EuCisgKi8KKworI2lmbmRlZiBfX0xJTlVYX0ZF
Q19ICisjZGVmaW5lIF9fTElOVVhfRkVDX0gKKworc3RydWN0IGZlY19lbmV0X3BsYXRmb3JtX2Rh
dGEgeworCXUzMiBwaHlfbWFzazsJLyogU2V0IHggYml0IHRvIG1hc2sgcGh5IGF0IGFkZHJlc3Mg
eCAqLworfTsKKworI2VuZGlmIC8qIF9fTElOVVhfRkVDX0ggKi8K
--0015174c3d1611c0ad046279d4e8--
