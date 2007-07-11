From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: optionaly validate RAs on raw sockets
Date: Wed, 11 Jul 2007 21:29:16 +0900 (JST)
Message-ID: <20070711.212916.36390936.yoshfuji@linux-ipv6.org>
References: <200707102111.18824@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: rdenis@simphalempin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:48006 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756696AbXGKM2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 08:28:41 -0400
In-Reply-To: <200707102111.18824@auguste.remlab.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <200707102111.18824@auguste.remlab.net> (at Tue, 10 Jul 2007 21:11:17 +0300), Remi Denis-Courmont <rdenis@simphalempin.com> says:

> ICMPv6 Router Advertisements may now contain informations that is
> mostly of interest to userland. This currently mostly consists of
> recursive DNS server addresses (though one should expect other
> stuff to come).

I really do not want to have such non-standard API in kernel.

--yoshfuji
