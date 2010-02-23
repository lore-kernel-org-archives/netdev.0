From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 14/15] drivers/net/typhoon.c: Use
 (pr|netdev)_<level> macro helpers
Date: Mon, 22 Feb 2010 16:45:36 -0800 (PST)
Message-ID: <20100222.164536.244367944.davem@davemloft.net>
References: <1266808995.2930.24.camel@obelisk.thedillows.org>
	<20100222.154306.114398657.davem@davemloft.net>
	<1266884549.2930.57.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: dave@thedillows.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36427
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751518Ab0BWApT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 19:45:19 -0500
In-Reply-To: <1266884549.2930.57.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Dillow <dave@thedillows.org>
Date: Mon, 22 Feb 2010 19:22:29 -0500

> On Mon, 2010-02-22 at 15:43 -0800, David Miller wrote:
>> Man you are picky :-/  Are you a control freak?
> 
> Sometimes, yes. Aren't you? ;)

Yes, I certainly can be :-)

> It doesn't matter for this driver, with its minimal user base. And it
> may not be worth the effort for the transformation series. But I think
> he's going to move into much larger projects and I believe it would be a
> good habit to develop.

Agreed.
