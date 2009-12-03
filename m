From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdevice: provide common routine for macvlan and vlan
 operstate management
Date: Thu, 03 Dec 2009 15:59:33 -0800 (PST)
Message-ID: <20091203.155933.218088805.davem@davemloft.net>
References: <4B105311.1020005@trash.net>
	<20091203201824.15789.7578.stgit@mimic.site>
	<200912032134.32338.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pmullaney@novell.com, netdev@vger.kernel.org, kaber@trash.net
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44992
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752266AbZLCX70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 18:59:26 -0500
In-Reply-To: <200912032134.32338.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 3 Dec 2009 21:34:32 +0000

> On Thursday 03 December 2009 20:21:54 Patrick Mullaney wrote:
>> Provide common routine for the transition of operational state for a leaf
>> device during a root device transition.
>> 
>> Signed-off-by: Patrick Mullaney <pmullaney@novell.com>
> 
> Acked-by: Arnd Bergmann <arnd@arndb.de>
> 
> The last time this was posted, we also had an "Acked-by: Patrick McHardy
> <kaber@trash.net>", which should be in there as well.

I've done that and applied this patch, thanks.
