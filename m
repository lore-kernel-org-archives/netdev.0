From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] tipc: updates for what will be v3.8
Date: Fri, 23 Nov 2012 14:10:56 -0500 (EST)
Message-ID: <20121123.141056.1152585667260141965.davem@davemloft.net>
References: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49376 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753700Ab2KWTK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 14:10:59 -0500
In-Reply-To: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 22 Nov 2012 15:59:45 -0500

> The most interesting thing here, at least from a user perspective,
> is the broadcast link fix -- where there was a corner case where
> two endpoints could get in a state where they disagree on where
> to start Rx and ack of broadcast packets.
> 
> There is also the poll/wait changes which could also impact
> end users for certain use cases - the fixes there also better
> align tipc with the rest of the networking code.
> 
> The rest largely falls into routine cleanup category, by getting
> rid of some unused routines, some Kconfig clutter, etc.
> 
> Assuming there is nothing that jumps out as needing a rework,
> the full set can be found as per below.

Pulled, thanks.
