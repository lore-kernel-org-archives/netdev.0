From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 6/8] ixgbe: Add infrastructure code for
 FCoE large receive offload to 82599
Date: Sun, 17 May 2009 13:58:24 -0700 (PDT)
Message-ID: <20090517.135824.15745847.davem@davemloft.net>
References: <20090513230924.11416.68752.stgit@localhost.localdomain>
	<20090513231129.11416.23975.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	yi.zou@intel.com, christopher.leech@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50549
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754630AbZEQU60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 16:58:26 -0400
In-Reply-To: <20090513231129.11416.23975.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 13 May 2009 16:11:29 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> This adds infrastructure code for FCoE Rx side offload feature to
> 82599, which provides large receive offload for FCoE by Direct
> Data Placement (DDP). The ixgbe_fcoe_ddp_get() and ixgbe_fcoe_ddp_put()
> pair corresponds to the netdev support to FCoE by the function pointers
> provided in net_device_ops as ndo_fcoe_ddp_setup and ndo_fcoe_ddp_done.
> The implementation of these in ixgbe is shown in the next patch.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Chris Leech <christopher.leech@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
