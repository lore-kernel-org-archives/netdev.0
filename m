From: David Miller <davem@davemloft.net>
Subject: Re: netem: loss model API sizes
Date: Fri, 23 Dec 2011 17:11:56 -0500 (EST)
Message-ID: <20111223.171156.1135770965682732913.davem@davemloft.net>
References: <20111223111630.52f9f6d7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757861Ab1LWWL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 17:11:58 -0500
In-Reply-To: <20111223111630.52f9f6d7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 23 Dec 2011 11:16:30 -0800

> The new netem loss model is configured with nested netlink messages.
> This code is being overly strict about sizes, and is easily confused
> by padding (or possible future expansion). Also message
> for gemodel is incorrect.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
