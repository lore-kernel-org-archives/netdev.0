From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/9] : fib_insert_node cleanup
Date: Sat, 12 Jan 2008 20:57:24 -0800 (PST)
Message-ID: <20080112.205724.247255013.davem@davemloft.net>
References: <20080112064513.803976049@linux-foundation.org>
	<20080112064646.432200237@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34526
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753662AbYAME5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 23:57:25 -0500
In-Reply-To: <20080112064646.432200237@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 11 Jan 2008 22:45:19 -0800

> The only error from fib_insert_node is if memory allocation fails,
> so instead of passing by reference, just use the convention of returning
> NULL.
> 
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

I'd be a hypocrite if I didn't apply this one :-)

Applied, thanks.
