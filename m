From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: fix up function prototypes after __dev*
 removals
Date: Fri, 07 Dec 2012 14:22:42 -0500 (EST)
Message-ID: <20121207.142242.425178853444743677.davem@davemloft.net>
References: <20121207003056.GA30167@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wfp5p@virginia.edu
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57770 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448Ab2LGTWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 14:22:44 -0500
In-Reply-To: <20121207003056.GA30167@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <gregkh@linuxfoundation.org>
Date: Thu, 6 Dec 2012 16:30:56 -0800

> From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> 
> The __dev* removal patches for the network drivers ended up messing up
> the function prototypes for a bunch of drivers.  This patch fixes all of
> them back up to be properly aligned.
> 
> Bonus is that this almost removes 100 lines of code, always a nice
> surprise.
> 
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Applied, thanks Greg.
