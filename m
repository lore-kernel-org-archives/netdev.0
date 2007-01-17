From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [IPV6] fixed the size of the netlink message notified by inet6_rt_notify().
Date: Wed, 17 Jan 2007 11:50:06 +0100
Message-ID: <20070117105006.GV8693@postel.suug.ch>
References: <20070116.125728.278729390.takamiya@po.ntts.co.jp> <20070116.140159.02303722.takamiya@po.ntts.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:38044 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932280AbXAQKtq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jan 2007 05:49:46 -0500
To: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Content-Disposition: inline
In-Reply-To: <20070116.140159.02303722.takamiya@po.ntts.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Noriaki TAKAMIYA <takamiya@po.ntts.co.jp> 2007-01-16 14:01
> Hi,
> 
>   I'm sorry to re-send...
> 
>   I think the return value of rt6_nlmsg_size() should includes the
>   amount of RTA_METRICS.
> 
>   Regards,
> 
> Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>

Acked-by: Thomas Graf <tgraf@suug.ch>
