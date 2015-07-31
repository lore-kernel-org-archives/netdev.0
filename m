From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] Microchip's LAN7800 family USB 2/3 to
 10/100/1000 Ethernet device driver
Date: Fri, 31 Jul 2015 15:19:15 -0700 (PDT)
Message-ID: <20150731.151915.1788101742098740589.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D538C9D@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51483 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077AbbGaWTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:19:16 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D538C9D@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Thu, 30 Jul 2015 19:45:21 +0000

> Repost patch of driver for LAN7800 family of USB 2.0 & USB 3.0 to Gigabit E=
> thernet.
> - remove module param which can be configurable by standard mechanism.
> - remove other module parms except msg_level per review comment.
> - update to handle byte swap for statistics structure correctly.
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

Applied, thanks.
