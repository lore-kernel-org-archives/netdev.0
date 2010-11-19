From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix kernel-doc for sk_filter_rcu_release
Date: Fri, 19 Nov 2010 09:27:27 -0800 (PST)
Message-ID: <20101119.092727.39181798.davem@davemloft.net>
References: <20101118150237.1f0ba4b5.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43197
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754738Ab0KSR1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 12:27:02 -0500
In-Reply-To: <20101118150237.1f0ba4b5.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 18 Nov 2010 15:02:37 -0800

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix kernel-doc warning for sk_filter_rcu_release():
> 
> Warning(net/core/filter.c:586): missing initial short description on line:
>  * 	sk_filter_rcu_release: Release a socket filter by rcu_head
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.
