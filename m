From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND 2.6.27] netlink: Remove compat API for nested
 attributes
Date: Tue, 02 Sep 2008 17:30:34 -0700 (PDT)
Message-ID: <20080902.173034.145487450.davem@davemloft.net>
References: <20080828140050.GB20815@postel.suug.ch>
	<20080828140527.GC20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35143
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754310AbYICAak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 20:30:40 -0400
In-Reply-To: <20080828140527.GC20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 28 Aug 2008 16:05:27 +0200

> Removes all _nested_compat() functions from the API. The prio qdisc
> no longer requires them and netem has its own format anyway. Their
> existance is only confusing.
> 
> Resend: Also remove the wrapper macro.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied to net-next-2.6, thanks Thomas.
