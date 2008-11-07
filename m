From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipvs: oldlen, newlen should be be16, not be32
Date: Thu, 06 Nov 2008 23:10:12 -0800 (PST)
Message-ID: <20081106.231012.95062942.davem@davemloft.net>
References: <1226023925.5482.2.camel@brick>
	<20081107022814.GA18907@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harvey.harrison@gmail.com, netdev@vger.kernel.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56522
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751211AbYKGHKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 02:10:20 -0500
In-Reply-To: <20081107022814.GA18907@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Fri, 7 Nov 2008 13:28:14 +1100

> On Thu, Nov 06, 2008 at 06:12:05PM -0800, Harvey Harrison wrote:
> > Noticed by sparse:
 ...
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> 
> I suspect these were introduced by me :-(
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Applied to net-next-2.6, thanks everyone.
