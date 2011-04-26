From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 0/7] SCTP updates for net-next-2.6
Date: Tue, 26 Apr 2011 00:12:38 -0700 (PDT)
Message-ID: <20110426.001238.183056292.davem@davemloft.net>
References: <4DB63F85.2090609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44202
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757456Ab1DZHNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 03:13:12 -0400
In-Reply-To: <4DB63F85.2090609@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 26 Apr 2011 11:44:05 +0800

> Hi David
> 
> Here is a set of SCTP patches for net-next-2.6, the last part
> from vlad's lksctp-dev tree, update SCTP IPv6 routing and IPSec
> issues. Please apply.
> 
> Vlad Yasevich (4):
>       sctp: cache the ipv6 source after route lookup
>       sctp: make sctp over IPv6 work with IPsec
>       sctp: remove useless arguments from get_saddr() call
>       sctp: clean up route lookup calls
> 
> Wei Yongjun (2):
>       sctp: clean up IPv6 route and XFRM lookups
>       sctp: fix IPv6 source address output routing with IPsec
> 
> Weixing Shi (1):
>       sctp: fix sctp to work with ipv6 source address routing

All applied, with the warning fixed.
