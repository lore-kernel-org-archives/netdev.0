From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-2.6.26] [IPV6] Adjust IPV6 multicast routing module
 (ip6mr.c) to use mroute6 header declarations .
Date: Fri, 11 Apr 2008 18:11:19 +0900 (JST)
Message-ID: <20080411.181119.12087415.yoshfuji@linux-ipv6.org>
References: <eb3ff54b0804100240x2cc3d21el3ce06b21ce7b5320@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33299 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758102AbYDKJJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 05:09:35 -0400
In-Reply-To: <eb3ff54b0804100240x2cc3d21el3ce06b21ce7b5320@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <eb3ff54b0804100240x2cc3d21el3ce06b21ce7b5320@mail.gmail.com> (at Thu, 10 Apr 2008 12:40:10 +0300), "Rami Rosen" <ramirose@gmail.com> says:

> Hi,
> - This patch adjusts IPv6 multicast routing module, net/ipv6/ip6mr.c,
> to use mroute6 header definitions instead of mroute.
>  (MFC6_LINES instead of MFC_LINES, MAXMIFS instead of MAXVIFS, mifi_t
> instead of vifi_t.)
> 
> - In addition, inclusion of some headers was removed as it is not needed.
> 
> Regards,
> Rami Rosen

Applied, thanks.

--yoshfuji
