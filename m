From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: Use affinity_hint when Flow
 Director is enabled
Date: Wed, 06 Oct 2010 23:48:23 -0700 (PDT)
Message-ID: <20101006.234823.241942525.davem@davemloft.net>
References: <20101005112511.23263.64121.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40423
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751799Ab0JGGsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 02:48:02 -0400
In-Reply-To: <20101005112511.23263.64121.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 05 Oct 2010 04:27:49 -0700

> From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> Use the new infrastructure to balance interrupts for flow
> alignment when ATR or Flow Director are enabled.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
