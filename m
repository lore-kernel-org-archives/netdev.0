From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/2] AES-XCBC-MAC
Date: Wed, 14 Jun 2006 01:10:44 +0900 (JST)
Message-ID: <20060614.011044.122508954.yoshfuji@linux-ipv6.org>
References: <1150213440.4200.36.camel@hookipa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:20484 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932160AbWFMQJ6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 12:09:58 -0400
To: kazunori@miyazawa.org
In-Reply-To: <1150213440.4200.36.camel@hookipa>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <1150213440.4200.36.camel@hookipa> (at Wed, 14 Jun 2006 00:44:00 +0900), Kazunori MIYAZAWA <kazunori@miyazawa.org> says:

> This is preparation to introduce AES-XCBC-MAC.
> - introducing common interface "keyed hash"
> - making HMAC use the interface

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

BTW, why not sign off?

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
