From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] WAN: remove deprecated PCI_DEVICE_ID from PCI200SYN
 driver.
Date: Fri, 04 Sep 2009 23:07:40 -0700 (PDT)
Message-ID: <20090904.230740.247551288.davem@davemloft.net>
References: <m363byk3af.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49397
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750986AbZIEGHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2009 02:07:25 -0400
In-Reply-To: <m363byk3af.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Fri, 04 Sep 2009 19:50:16 +0200

> PCI200SYN has its own PCI subsystem device ID for 3+ years, now it's
> time to remove the generic PLX905[02] ID from the driver. Anyone with
> old EEPROM data will have to run the upgrade.
> 
> Having the generic PLX905[02] (PCI-local bus bridge) ID is harmful
> as the driver tries to handle other devices based on these bridges.

Please provide a proper signoff with all patches.

Thanks.
