From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6] fixed the size of the netlink message notified
 by inet6_rt_notify().
Date: Tue, 23 Jan 2007 22:10:01 -0800 (PST)
Message-ID: <20070123.221001.75430936.davem@davemloft.net>
References: <20070116.125728.278729390.takamiya@po.ntts.co.jp>
	<20070116.140159.02303722.takamiya@po.ntts.co.jp>
	<20070117105006.GV8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: takamiya@po.ntts.co.jp, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42587
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030243AbXAXGKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 01:10:07 -0500
In-Reply-To: <20070117105006.GV8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 17 Jan 2007 11:50:06 +0100

> * Noriaki TAKAMIYA <takamiya@po.ntts.co.jp> 2007-01-16 14:01
> > Hi,
> > 
> >   I'm sorry to re-send...
> > 
> >   I think the return value of rt6_nlmsg_size() should includes the
> >   amount of RTA_METRICS.
> > 
> >   Regards,
> > 
> > Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Noriaki.
