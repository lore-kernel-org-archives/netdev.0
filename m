From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] usbnet & cdc-ether: Autosuspend for online devices
Date: Fri, 04 Dec 2009 00:58:20 -0800 (PST)
Message-ID: <20091204.005820.166774873.davem@davemloft.net>
References: <20091203.134532.225926933.davem@davemloft.net>
	<20091203.152721.266674825.davem@davemloft.net>
	<200912040914.19339.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53481
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754721AbZLDI6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 03:58:14 -0500
In-Reply-To: <200912040914.19339.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Fri, 4 Dec 2009 09:14:18 +0100

> Am Freitag, 4. Dezember 2009 00:27:21 schrieb David Miller:
>> From: David Miller <davem@davemloft.net>
>> Date: Thu, 03 Dec 2009 13:45:32 -0800 (PST)
>> 
>> > But this all might be due to some other changes I applied today and
>> > didn't push out yet to net-next-2.6, let me check on that for you.
>> 
>> I've resolved this, it was a conflict with Joe Perches's drivers/net
>> coding style cleanups that went in today.
> 
> OK, so you don't need me to respin on a newer tree?

Nope.

> I was doubting my own sanity.

:-)
