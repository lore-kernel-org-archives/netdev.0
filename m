From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6] fix sysctl compilation error
Date: Tue, 05 Feb 2008 02:58:08 -0800 (PST)
Message-ID: <20080205.025808.127966085.davem@davemloft.net>
References: <47A827ED.6000908@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39994
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756210AbYBEK5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 05:57:40 -0500
In-Reply-To: <47A827ED.6000908@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Tue, 05 Feb 2008 10:10:05 +0100

> Subject: fix sysctl compilation error
> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> Move ipv6_icmp_sysctl_init and ipv6_route_sysctl_init into
> the right ifdef section otherwise that does not compile when
> CONFIG_SYSCTL=yes and CONFIG_PROC_FS=no
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks.
