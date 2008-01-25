From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [patch net-2.6.25][IPV6][SYSCTL] fix sysctl compilation error
Date: Fri, 25 Jan 2008 22:40:25 +0900 (JST)
Message-ID: <20080125.224025.79919427.yoshfuji@linux-ipv6.org>
References: <4799E4E7.5020000@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:39469 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754707AbYAYNkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 08:40:07 -0500
In-Reply-To: <4799E4E7.5020000@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <4799E4E7.5020000@fr.ibm.com> (at Fri, 25 Jan 2008 14:32:23 +0100), Daniel Lezcano <dlezcano@fr.ibm.com> says:

> Move ipv6_icmp_sysctl_init and ipv6_route_sysctl_init into
> the right ifdef section otherwise that does not compile when
> CONFIG_SYSCTL=yes and CONFIG_PROC_FS=no
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

My bad....

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
