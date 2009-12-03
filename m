From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] usbnet & cdc-ether: Autosuspend for online devices
Date: Thu, 03 Dec 2009 15:27:21 -0800 (PST)
Message-ID: <20091203.152721.266674825.davem@davemloft.net>
References: <200912032241.43772.oliver@neukum.org>
	<20091203.134532.225926933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48579
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753324AbZLCX1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 18:27:15 -0500
In-Reply-To: <20091203.134532.225926933.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 03 Dec 2009 13:45:32 -0800 (PST)

> But this all might be due to some other changes I applied today and
> didn't push out yet to net-next-2.6, let me check on that for you.

I've resolved this, it was a conflict with Joe Perches's drivers/net
coding style cleanups that went in today.
