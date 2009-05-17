From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/8] ixgbe: Add FCoE feature code to 82599
Date: Sun, 17 May 2009 13:58:08 -0700 (PDT)
Message-ID: <20090517.135808.78943719.davem@davemloft.net>
References: <20090513230924.11416.68752.stgit@localhost.localdomain>
	<20090513231021.11416.9456.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	yi.zou@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090513231021.11416.9456.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 13 May 2009 16:10:21 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> This adds the FCoE feature code ixgbe_fcoe.c to 82599. For a start, this patch
> only adds ixgbe_configure_fcoe() to configure related register for FCoE to 82599.
> In patches that follow, I will be adding more functions to ixgbe_fcoe.c to add
> support of FCoE offload features to 82599.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
