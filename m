From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] updated cxgb4 submission v6
Date: Thu, 01 Apr 2010 19:31:32 -0700 (PDT)
Message-ID: <20100401.193132.201220327.davem@davemloft.net>
References: <1270171707-26058-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47956
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754758Ab0DBCbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 22:31:31 -0400
In-Reply-To: <1270171707-26058-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Thu,  1 Apr 2010 17:28:21 -0800

> 
> This is an updated patch series for the cxgb4 driver.  Changes from previous
> version:
> 
> - Replaced __u* types with u*
> - Of the proc files I kept one and moved it to debugfs (it dumps a largish
> table, it's not a good fit for a value-per-file model).  I've removed all
> the other proc files.  I'll look at making some of their information available
> in sysfs as separate work.
> 
> The patches are against net-next as of 6c57990.

Ok, this looks good enough now, thanks.

Since it's a self-contained new driver I've added it to net-2.6

Thanks.
