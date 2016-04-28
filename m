From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net] lan78xx: workaround of forced 100 Full/Half
 duplex mode error
Date: Thu, 28 Apr 2016 16:36:38 -0400 (EDT)
Message-ID: <20160428.163638.492232995397566923.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D408987FF@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164AbcD1Ugj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 16:36:39 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D408987FF@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Mon, 25 Apr 2016 22:22:36 +0000

> From: Woojung Huh <woojung.huh@microchip.com>
> 
> At forced 100 Full & Half duplex mode, chip may fail to set mode correctly
> when cable is switched between long(~50+m) and short one.
> As workaround, set to 10 before setting to 100 at forced 100 F/H mode.
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

Applied.
