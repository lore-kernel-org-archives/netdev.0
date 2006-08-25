From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 0/3] [IPV6] Policy Routing Updates
Date: Sat, 26 Aug 2006 00:08:36 +0900 (JST)
Message-ID: <20060826.000836.19211008.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:52746 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S964826AbWHYPGr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 11:06:47 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Here's some IPv6 policy rouging fixes on top of net-2.6.19 tree.

  [PATCH 1/3] [IPV6] ROUTE: Fix FWMARK support.
  [PATCH 2/3] [IPV6] ROUTE: Fix size of fib6_rule_policy.

If we accept Patrick's IPv4 fwmask patch, here's the one for IPv6.

  [PATCH 3/3] [IPV6] ROUTE: Add support for fwmask in routing rules.

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
