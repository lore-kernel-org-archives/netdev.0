From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] ixgbe: Change Direct Attach Twinax
 cable detection for SFP+ NICs
Date: Tue, 19 May 2009 14:41:05 -0700 (PDT)
Message-ID: <20090519.144105.260898332.davem@davemloft.net>
References: <20090519191819.5063.28388.stgit@localhost.localdomain>
	<20090519191851.5063.42840.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37758
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752665AbZESVlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 17:41:07 -0400
In-Reply-To: <20090519191851.5063.42840.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 19 May 2009 12:18:51 -0700

> The SFF specification for Direct Attach cable detection has now been
> ratified.  Previously, DA cable detect was looking at the Twinaxial bit in
> byte 9 of the SFP+ EEPROM.  The spec now defines active and passive DA
> cables in byte 8 of the SFP+ EEPROM.  This patch changes the cable
> detection for both 82598 and 82599 SFP+ adapters to conform to the new
> spec.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
