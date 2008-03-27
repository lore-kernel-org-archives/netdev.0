From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.26] Remove three unused method declarations in include/net/ipv6.h
Date: Thu, 27 Mar 2008 11:05:55 +0200
Message-ID: <eb3ff54b0803270205n4a15a884kaa45852e510b27c6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_14242_33134566.1206608755587"
Cc: linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:62711 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753820AbYC0JF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 05:05:57 -0400
Received: by fg-out-1718.google.com with SMTP id l27so4451154fgb.17
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 02:05:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_14242_33134566.1206608755587
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
This patch removes three unused method declarations in include/net/ipv6.h:
inet_getfrag_t(), ipv6_build_nfrag_opts() and ipv6_build_frag_opts().

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_14242_33134566.1206608755587
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_feb3g0hc0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2lwdjYuaCBiL2luY2x1ZGUvbmV0L2lwdjYuaAppbmRl
eCAyOTZmNjFkLi41NzM4YzFjIDEwMDY0NAotLS0gYS9pbmNsdWRlL25ldC9pcHY2LmgKKysrIGIv
aW5jbHVkZS9uZXQvaXB2Ni5oCkBAIC0yNTAsMTUgKzI1MCw2IEBAIGludCBpcDZfZnJhZ19tZW0o
c3RydWN0IG5ldCAqbmV0KTsKIAogI2RlZmluZSBJUFY2X0ZSQUdfVElNRU9VVAkoNjAqSFopCQkv
KiA2MCBzZWNvbmRzICovCiAKLS8qCi0gKglGdW5jdGlvbiBwcm90b3R5cGUgZm9yIGJ1aWxkX3ht
aXQKLSAqLwotCi10eXBlZGVmIGludAkJKCppbmV0X2dldGZyYWdfdCkgKGNvbnN0IHZvaWQgKmRh
dGEsCi0JCQkJCSAgIHN0cnVjdCBpbjZfYWRkciAqYWRkciwKLQkJCQkJICAgY2hhciAqLAotCQkJ
CQkgICB1bnNpZ25lZCBpbnQsIHVuc2lnbmVkIGludCk7Ci0KIGV4dGVybiBpbnQgX19pcHY2X2Fk
ZHJfdHlwZShjb25zdCBzdHJ1Y3QgaW42X2FkZHIgKmFkZHIpOwogc3RhdGljIGlubGluZSBpbnQg
aXB2Nl9hZGRyX3R5cGUoY29uc3Qgc3RydWN0IGluNl9hZGRyICphZGRyKQogewpAQCAtNTEwLDE0
ICs1MDEsNiBAQCBleHRlcm4gaW50CQkJaXA2X2xvY2FsX291dChzdHJ1Y3Qgc2tfYnVmZiAqc2ti
KTsKICAqCUV4dGVuc2lvbiBoZWFkZXIgKG9wdGlvbnMpIHByb2Nlc3NpbmcKICAqLwogCi1leHRl
cm4gdTggKgkJCWlwdjZfYnVpbGRfbmZyYWdfb3B0cyhzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAotCQkJ
CQkJICAgICAgdTggKnByZXZfaGRyLAotCQkJCQkJICAgICAgc3RydWN0IGlwdjZfdHhvcHRpb25z
ICpvcHQsCi0JCQkJCQkgICAgICBzdHJ1Y3QgaW42X2FkZHIgKmRhZGRyLAotCQkJCQkJICAgICAg
dTMyIGp1bWJvbGVuKTsKLWV4dGVybiB1OCAqCQkJaXB2Nl9idWlsZF9mcmFnX29wdHMoc3RydWN0
IHNrX2J1ZmYgKnNrYiwKLQkJCQkJCSAgICAgdTggKnByZXZfaGRyLAotCQkJCQkJICAgICBzdHJ1
Y3QgaXB2Nl90eG9wdGlvbnMgKm9wdCk7CiBleHRlcm4gdm9pZCAJCQlpcHY2X3B1c2hfbmZyYWdf
b3B0cyhzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAogCQkJCQkJICAgICBzdHJ1Y3QgaXB2Nl90eG9wdGlv
bnMgKm9wdCwKIAkJCQkJCSAgICAgdTggKnByb3RvLAo=
------=_Part_14242_33134566.1206608755587--
