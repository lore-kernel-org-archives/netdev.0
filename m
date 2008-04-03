From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL net-2.6.26] [IPV6] MROUTE: Support multicast routing.
Date: Thu, 03 Apr 2008 15:23:41 +0900 (JST)
Message-ID: <20080403.152341.59206559.yoshfuji@linux-ipv6.org>
References: <20080403.114333.77827256.yoshfuji@linux-ipv6.org>
	<147a89290804022314w7968fd47y7de78a9e87c2d289@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: johnsonzjo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:60148 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760648AbYDCGWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 02:22:05 -0400
In-Reply-To: <147a89290804022314w7968fd47y7de78a9e87c2d289@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <147a89290804022314w7968fd47y7de78a9e87c2d289@mail.gmail.com> (at Thu, 3 Apr 2008 09:14:00 +0300), "Andy Johnson" <johnsonzjo@gmail.com> says:

> 1) I downlaoded the mcast-tools git tree. There is no configure script there
> and no Makefile. How is it to build ?

aclocal; automake; autoconf

> 2) Typo correction: it should be
> git://git.linux-ipv6.org/gitroot/yoshfuji/mcast-tools.git
> 
> and not
> git:/git.linux-ipv6.org/gitroot/yoshfuji/mcast-tools.git

Right.

> 3) I had looked for some info about Multicast Routing; I found
> Chapter 2 in "IPv6 Advanced Protocols Implementation" book.
> But it talks about kame project.
> It talks about  Protocol Independent Multicast (PIM), PIM version 2,
> MLD , BSD implementation, and more.

Make a Linux box a multicast (PIM-SM (SSM), say PIMv2) router.

--yoshfuji
