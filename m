From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: Re: IPSEC IPV4 Tunnel Requires IPV6 WIth 2.6.25?
Date: Wed, 21 May 2008 21:17:04 +0900
Message-ID: <483412C0.2060404@miyazawa.org>
References: <1210882182.9684.27.camel@zeus.local> <48340F01.6050104@miyazawa.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_catalunya.miyazawa.org-13928-1211371612-0001-2"
Cc: netdev@vger.kernel.org
To: Alan Swanson <swanson@ukfsn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:51629 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758512AbYEUMRS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2008 08:17:18 -0400
In-Reply-To: <48340F01.6050104@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_catalunya.miyazawa.org-13928-1211371612-0001-2
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit

Kazunori MIYAZAWA さんは書きました:
> Hello,
> 
> This patch fixes the problem.
> I though that someone (sorry I foget) sent the same patch
> when netlink was fixed.
> 

Sorry I did typo.

--
Kazunori Miyazawa

--=_catalunya.miyazawa.org-13928-1211371612-0001-2
Content-Type: text/plain; name="patch-fixing-af_key.txt"; charset=iso-8859-1
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="patch-fixing-af_key.txt"

c2lnbmVkLW9mZi1ieTogS2F6dW5vcmkgTUlZQVpBV0EgPGthenVub3JpQG1peWF6YXdhLm9y
Zz4KCmRpZmYgLS1naXQgYS9uZXQva2V5L2FmX2tleS5jIGIvbmV0L2tleS9hZl9rZXkuYwpp
bmRleCBlOWVmOWFmLi44MzVlMzA3IDEwMDY0NAotLS0gYS9uZXQva2V5L2FmX2tleS5jCisr
KyBiL25ldC9rZXkvYWZfa2V5LmMKQEAgLTEyMTksNyArMTIxOSw3IEBAIHN0YXRpYyBzdHJ1
Y3QgeGZybV9zdGF0ZSAqIHBma2V5X21zZzJ4ZnJtX3N0YXRlKHN0cnVjdCBzYWRiX21zZyAq
aGRyLAogICAgICAgICAgICAgICAgeC0+c2VsLnByZWZpeGxlbl9zID0gYWRkci0+c2FkYl9h
ZGRyZXNzX3ByZWZpeGxlbjsKICAgICAgICB9CiAKLSAgICAgICBpZiAoeC0+cHJvcHMubW9k
ZSA9PSBYRlJNX01PREVfVFJBTlNQT1JUKQorICAgICAgIGlmICgheC0+c2VsLmZhbWlseSkK
ICAgICAgICAgICAgICAgIHgtPnNlbC5mYW1pbHkgPSB4LT5wcm9wcy5mYW1pbHk7CiAKICAg
ICAgICBpZiAoZXh0X2hkcnNbU0FEQl9YX0VYVF9OQVRfVF9UWVBFLTFdKSB7Cgo=
--=_catalunya.miyazawa.org-13928-1211371612-0001-2--
