From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netlink: af_netlink cleanup (v2)
Date: Thu, 22 Dec 2011 22:37:57 -0500 (EST)
Message-ID: <20111222.223757.363583888345084579.davem@davemloft.net>
References: <20111222185201.592156795@vyatta.com>
	<20111222185217.411768888@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab1LWDh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 22:37:59 -0500
In-Reply-To: <20111222185217.411768888@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 22 Dec 2011 10:52:02 -0800

> Don't inline functions that cover several lines, and do inline
> the trivial ones. Also make some arguments const.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
