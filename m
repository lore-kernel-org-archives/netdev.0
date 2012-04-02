From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/8] net/ipv6/addrconf.c: Checkpatch cleanups
Date: Sun, 01 Apr 2012 23:07:51 -0400 (EDT)
Message-ID: <20120401.230751.1548812352573439731.davem@davemloft.net>
References: <1333302548-9187-1-git-send-email-eldad@fogrefinery.com>
	<1333302548-9187-8-git-send-email-eldad@fogrefinery.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eldad@fogrefinery.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797Ab2DBDK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:10:26 -0400
In-Reply-To: <1333302548-9187-8-git-send-email-eldad@fogrefinery.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eldad Zack <eldad@fogrefinery.com>
Date: Sun,  1 Apr 2012 19:49:08 +0200

> net/ipv6/addrconf.c:340: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
> net/ipv6/addrconf.c:342: ERROR: "foo * bar" should be "foo *bar"
> net/ipv6/addrconf.c:444: ERROR: "foo * bar" should be "foo *bar"
> net/ipv6/addrconf.c:1337: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
> net/ipv6/addrconf.c:1526: ERROR: "(foo*)" should be "(foo *)"
> net/ipv6/addrconf.c:1671: ERROR: open brace '{' following function declarations go on the next line
> net/ipv6/addrconf.c:1914: ERROR: "foo * bar" should be "foo *bar"
> net/ipv6/addrconf.c:2368: ERROR: "foo * bar" should be "foo *bar"
> net/ipv6/addrconf.c:2370: ERROR: "foo * bar" should be "foo *bar"
> net/ipv6/addrconf.c:2416: ERROR: "foo * bar" should be "foo *bar"
> net/ipv6/addrconf.c:2437: ERROR: "foo    * bar" should be "foo    *bar"
> net/ipv6/addrconf.c:2573: ERROR: "foo * bar" should be "foo *bar"
> net/ipv6/addrconf.c:3797: ERROR: "foo* bar" should be "foo *bar"
> 
> Signed-off-by: Eldad Zack <eldad@fogrefinery.com>

Applied.
