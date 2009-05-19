From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] ixgbe: Add semaphore access for PHY
 initialization for 82599
Date: Tue, 19 May 2009 14:40:58 -0700 (PDT)
Message-ID: <20090519.144058.158807288.davem@davemloft.net>
References: <20090519191819.5063.28388.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37755
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750887AbZESVlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 17:41:00 -0400
In-Reply-To: <20090519191819.5063.28388.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 19 May 2009 12:18:34 -0700

> The SFP+ NIC (device id 0x10fb) needs a semaphore to serialize
> PHY access, so our PHY init code must honor that same semaphore.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
