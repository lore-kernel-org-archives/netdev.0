From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Tue, 16 Feb 2016 16:40:21 -0500 (EST)
Message-ID: <20160216.164021.538472403639953008.davem@davemloft.net>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com>
	<20160216205756.GD2558@lunn.ch>
	<90A7E81AE28BAE4CBDDB3B35F187D264402EFB92@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbcBPVkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 16:40:22 -0500
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402EFB92@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Bryan.Whitehead@microchip.com>
Date: Tue, 16 Feb 2016 21:37:40 +0000

> Again, I'd like to change our target device to LAN9250, which is just an Ethernet controller with no switch. 
> 
> Will a driver for that device be more easily accepted?

No, please just implement your driver correctly instead of trying to side-step
the issue.
