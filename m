From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [XFRM] Remove unused XFRM_STATE_VOID and typos (net/xfrm.h)
Date: Sat, 12 Jan 2008 13:37:34 +0200
Message-ID: <eb3ff54b0801120337w2b49ef4bsfb805ac8d28dc712@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_1902_19838650.1200137854660"
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:18767 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754755AbYALLhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 06:37:36 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1481281fga.17
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2008 03:37:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_1902_19838650.1200137854660
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

In net/xfrm.h:
- remove XFRM_STATE_VOID (not in use)
- correct 3 typos
	
Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_1902_19838650.1200137854660
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fbc2wpm90
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L3hmcm0uaCBiL2luY2x1ZGUvbmV0L3hmcm0uaAppbmRl
eCA4NjBmZTRhLi40MzJjNWM4IDEwMDY0NAotLS0gYS9pbmNsdWRlL25ldC94ZnJtLmgKKysrIGIv
aW5jbHVkZS9uZXQveGZybS5oCkBAIC04NCwxMCArODQsMTAgQEAgZXh0ZXJuIHN0cnVjdCBtdXRl
eCB4ZnJtX2NmZ19tdXRleDsKICAgICAgICAgICAgICAgICAgICAgIHwtLS0uIGNoaWxkIC4tPiBk
c3QgLS4geGZybSAuLT4geGZybV9zdGF0ZSAjMwogICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICB8LS0tLiBjaGlsZCAuLT4gTlVMTAogCi0gICBCdW5kbGVzIGFyZSBjYWNoZWQg
YXQgeHJmbV9wb2xpY3kgc3RydWN0IChmaWVsZCAtPmJ1bmRsZXMpLgorICAgQnVuZGxlcyBhcmUg
Y2FjaGVkIGF0IHhmcm1fcG9saWN5IHN0cnVjdCAoZmllbGQgLT5idW5kbGVzKS4KIAogCi0gICBS
ZXNvbHV0aW9uIG9mIHhyZm1fdG1wbAorICAgUmVzb2x1dGlvbiBvZiB4ZnJtX3RtcGwKICAgIC0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tCiAgICBUZW1wbGF0ZSBjb250YWluczoKICAgIDEuIC0+bW9k
ZQkJTW9kZTogdHJhbnNwb3J0IG9yIHR1bm5lbApAQCAtMTMzLDcgKzEzMyw3IEBAIHN0cnVjdCB4
ZnJtX3N0YXRlCiAKIAl1MzIJCQlnZW5pZDsKIAotCS8qIEtleSBtYW5nZXIgYml0cyAqLworCS8q
IEtleSBtYW5hZ2VyIGJpdHMgKi8KIAlzdHJ1Y3QgewogCQl1OAkJc3RhdGU7CiAJCXU4CQlkeWlu
ZzsKQEAgLTIxNyw3ICsyMTcsNiBAQCBzdHJ1Y3QgeGZybV9zdGF0ZQogI2RlZmluZSBYRlJNX1RJ
TUVfREVGRVIJMQogCiBlbnVtIHsKLQlYRlJNX1NUQVRFX1ZPSUQsCiAJWEZSTV9TVEFURV9BQ1Es
CiAJWEZSTV9TVEFURV9WQUxJRCwKIAlYRlJNX1NUQVRFX0VSUk9SLAo=
------=_Part_1902_19838650.1200137854660--
