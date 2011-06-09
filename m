From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9] myricom: update to 64 bit stats
Date: Wed, 08 Jun 2011 23:27:14 -0700 (PDT)
Message-ID: <20110608.232714.184226971991664317.davem@davemloft.net>
References: <20110609005356.160260858@vyatta.com>
	<20110609005417.688902862@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, brice@myri.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753249Ab1FIG10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 02:27:26 -0400
In-Reply-To: <20110609005417.688902862@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 08 Jun 2011 17:54:03 -0700

> Driver was already keeping 64 bit counters, just not using the new interface.
> 
> Ps: IMHO drivers should not be duplicating network device
> stats into ethtool stats. It is useless duplication.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
