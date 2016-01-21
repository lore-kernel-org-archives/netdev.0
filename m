From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] net: phy: Finally fix PHY_IGNORE_INTERRUPTS
Date: Thu, 21 Jan 2016 10:49:13 -0800 (PST)
Message-ID: <20160121.104913.1642368497481013171.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D40499C4B@CHN-SV-EXMX02.mchp-main.com>
	<20160120.185809.1693986708113677599.davem@davemloft.net>
	<676328C4-2B92-4D32-917F-956F77032A83@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Woojung.Huh@microchip.com, netdev@vger.kernel.org, andrew@lunn.ch,
	sergei.shtylyov@cogentembedded.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbcAUStO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 13:49:14 -0500
In-Reply-To: <676328C4-2B92-4D32-917F-956F77032A83@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 20 Jan 2016 22:32:09 -0800

> On January 20, 2016 6:58:09 PM PST, David Miller <davem@davemloft.net> wrote:
>>From: <Woojung.Huh@microchip.com>
>>Date: Thu, 21 Jan 2016 00:59:42 +0000
>>
>>>  > I'm experiencing misbehavior after restart system.
>>>> Can you wait applying the patch?
>>>> 
>>>> Sorry about it.
>>>> Woojung
>>> 
>>> Sorry for spam. Version mismatch happened. :(
>>> It works as expected on USB-to-Ethernet point of view.
>>
>>So Florian, can I apply this series now?
> 
> Yes, sorry for the lag and thanks for your patience.

Great, series applied, thanks.
