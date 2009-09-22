From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/3] ixgbe: fix sfp_timer clean up in ixgbe_down
Date: Mon, 21 Sep 2009 22:37:36 -0700 (PDT)
Message-ID: <20090921.223736.154864076.davem@davemloft.net>
References: <20090918194533.28898.49436.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, shannon.nelson@intel.com,
	donald.c.skidmore@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45735
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754801AbZIVFhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 01:37:18 -0400
In-Reply-To: <20090918194533.28898.49436.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 18 Sep 2009 12:45:43 -0700

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> We weren't stoping the sfp_timer after the device was brought down.
> This patch properly cleans up.
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
