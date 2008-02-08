From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH] [IPV6] Replace using the magic constant "1024" with IP6_RT_PRIO_USER for fc_metric.
Date: Fri, 8 Feb 2008 12:14:18 +0200
Message-ID: <eb3ff54b0802080214u5c20f061of4144964c8776359@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_14217_32884298.1202465658715"
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:1587 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932870AbYBHKOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 05:14:20 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2865867fga.17
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2008 02:14:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_14217_32884298.1202465658715
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
  This patch replaces the explicit usage of the magic constant "1024"
with IP6_RT_PRIO_USER in the IPV6 tree.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_14217_32884298.1202465658715
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fcekxpen0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L3JvdXRlLmMgYi9uZXQvaXB2Ni9yb3V0ZS5jCmluZGV4IDUx
M2Y3MmUuLjZlN2I1NmUgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L3JvdXRlLmMKKysrIGIvbmV0L2lw
djYvcm91dGUuYwpAQCAtMTYyMCw3ICsxNjIwLDcgQEAgc3RhdGljIHN0cnVjdCBydDZfaW5mbyAq
cnQ2X2FkZF9yb3V0ZV9pbmZvKHN0cnVjdCBpbjZfYWRkciAqcHJlZml4LCBpbnQgcHJlZml4bGUK
IHsKIAlzdHJ1Y3QgZmliNl9jb25maWcgY2ZnID0gewogCQkuZmNfdGFibGUJPSBSVDZfVEFCTEVf
SU5GTywKLQkJLmZjX21ldHJpYwk9IDEwMjQsCisJCS5mY19tZXRyaWMJPSBJUDZfUlRfUFJJT19V
U0VSLAogCQkuZmNfaWZpbmRleAk9IGlmaW5kZXgsCiAJCS5mY19kc3RfbGVuCT0gcHJlZml4bGVu
LAogCQkuZmNfZmxhZ3MJPSBSVEZfR0FURVdBWSB8IFJURl9BRERSQ09ORiB8IFJURl9ST1VURUlO
Rk8gfApAQCAtMTY3MCw3ICsxNjcwLDcgQEAgc3RydWN0IHJ0Nl9pbmZvICpydDZfYWRkX2RmbHRf
cm91dGVyKHN0cnVjdCBpbjZfYWRkciAqZ3dhZGRyLAogewogCXN0cnVjdCBmaWI2X2NvbmZpZyBj
ZmcgPSB7CiAJCS5mY190YWJsZQk9IFJUNl9UQUJMRV9ERkxULAotCQkuZmNfbWV0cmljCT0gMTAy
NCwKKwkJLmZjX21ldHJpYwk9IElQNl9SVF9QUklPX1VTRVIsCiAJCS5mY19pZmluZGV4CT0gZGV2
LT5pZmluZGV4LAogCQkuZmNfZmxhZ3MJPSBSVEZfR0FURVdBWSB8IFJURl9BRERSQ09ORiB8IFJU
Rl9ERUZBVUxUIHwKIAkJCQkgIFJURl9VUCB8IFJURl9FWFBJUkVTIHwgUlRGX1BSRUYocHJlZiks
Cg==
------=_Part_14217_32884298.1202465658715--
