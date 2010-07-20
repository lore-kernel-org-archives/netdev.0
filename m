From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 4/5] ixgbe: use GFP_ATOMIC when allocating
 FCoE DDP context from the dma pool
Date: Mon, 19 Jul 2010 20:24:28 -0700 (PDT)
Message-ID: <20100719.202428.141223385.davem@davemloft.net>
References: <20100719235831.14112.14175.stgit@localhost.localdomain>
	<20100720000021.14112.63604.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37867
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758162Ab0GTDYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 23:24:12 -0400
In-Reply-To: <20100720000021.14112.63604.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 19 Jul 2010 17:00:24 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> The FCoE protocol stack may hold a lock when this gets called.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
