From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] tunnel: implement 64 bits statistics
Date: Sat, 14 Apr 2012 14:51:52 -0400 (EDT)
Message-ID: <20120414.145152.1082715881387108105.davem@davemloft.net>
References: <20120412163115.076119065@vyatta.com>
	<20120412163142.441631834@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59409 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755102Ab2DNSvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 14:51:54 -0400
In-Reply-To: <20120412163142.441631834@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 12 Apr 2012 09:31:16 -0700

> Convert the per-cpu statistics kept for GRE, IPIP, and SIT tunnels
> to use 64 bit statistics.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Looks good, applied.
