From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] IPv6: remove trivial nested _bh suffix
Date: Fri, 12 Feb 2010 12:30:28 -0800 (PST)
Message-ID: <20100212.123028.266223031.davem@davemloft.net>
References: <20100208214805.1f8f2c6d@nehalam>
	<20100208214852.017349dd@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52558
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757690Ab0BLUaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 15:30:13 -0500
In-Reply-To: <20100208214852.017349dd@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 8 Feb 2010 21:48:52 -0800

> Don't need to disable bottom half it is already down in the
> previous lock. Move some blank lines to group locking in same
> context.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next-2.6
