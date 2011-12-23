From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netlink: wake up netlink listeners sooner (v2)
Date: Thu, 22 Dec 2011 22:38:02 -0500 (EST)
Message-ID: <20111222.223802.1520286045158797497.davem@davemloft.net>
References: <20111222185201.592156795@vyatta.com>
	<20111222185217.507023273@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754107Ab1LWDiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 22:38:05 -0500
In-Reply-To: <20111222185217.507023273@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 22 Dec 2011 10:52:03 -0800

> This patch changes it to yield sooner at halfway instead. Still not a cure-all
> for listener overrun if listner is slow, but works much reliably.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
