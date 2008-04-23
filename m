From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH 3/3] [IPV6] Remove IFA_GLOBAL definition from include/net/if_inet6.h.
Date: Wed, 23 Apr 2008 14:36:58 +0300
Message-ID: <eb3ff54b0804230436o396f3014w9a116f38a57c58a4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_13643_23289438.1208950619018"
To: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	"David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:16886 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754289AbYDWLhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 07:37:07 -0400
Received: by fg-out-1718.google.com with SMTP id l27so2593313fgb.17
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 04:36:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_13643_23289438.1208950619018
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
This patches removes IFA_GLOBAL definition from linux/include/net/if_inet6.h
as it is unused.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_13643_23289438.1208950619018
Content-Type: text/plain; name=patch3.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ffdty0sr0
Content-Disposition: attachment; filename=patch3.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2lmX2luZXQ2LmggYi9pbmNsdWRlL25ldC9pZl9pbmV0
Ni5oCmluZGV4IGIyY2ZjNDkuLmRiNjZjNzkgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbmV0L2lmX2lu
ZXQ2LmgKKysrIGIvaW5jbHVkZS9uZXQvaWZfaW5ldDYuaApAQCAtMTQ4LDcgKzE0OCw2IEBAIHN0
cnVjdCBpZmFjYWRkcjYKICNkZWZpbmUJSUZBX0hPU1QJSVBWNl9BRERSX0xPT1BCQUNLCiAjZGVm
aW5lCUlGQV9MSU5LCUlQVjZfQUREUl9MSU5LTE9DQUwKICNkZWZpbmUJSUZBX1NJVEUJSVBWNl9B
RERSX1NJVEVMT0NBTAotI2RlZmluZQlJRkFfR0xPQkFMCTB4MDAwMFUKIAogc3RydWN0IGlwdjZf
ZGV2c3RhdCB7CiAJc3RydWN0IHByb2NfZGlyX2VudHJ5CSpwcm9jX2Rpcl9lbnRyeTsK
------=_Part_13643_23289438.1208950619018--
