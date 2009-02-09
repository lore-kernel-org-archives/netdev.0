From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: fix to set device name when new IPv6 over IPv6
 tunnel device is created.
Date: Mon, 09 Feb 2009 15:01:37 -0800 (PST)
Message-ID: <20090209.150137.90952382.davem@davemloft.net>
References: <20090210.034642.74753917.takamiya@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, takamiya@po.ntts.co.jp,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@ml.linux-ipv6.org
To: takamiya@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43520
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753287AbZBIXBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 18:01:43 -0500
In-Reply-To: <20090210.034642.74753917.takamiya@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Noriaki TAKAMIYA <takamiya@linux-ipv6.org>
Date: Tue, 10 Feb 2009 03:46:42 +0900 (JST)

>   When the user creates IPv6 over IPv6 tunnel, the device name created
>   by the kernel isn't set to t->parm.name, which is referred as the
>   result of ioctl().
> 
>   Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>

Patch applied, thank you.
