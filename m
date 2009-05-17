From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 8/8] ixgbe: Add FCoE related statistics to
 82599
Date: Sun, 17 May 2009 13:58:34 -0700 (PDT)
Message-ID: <20090517.135834.179767412.davem@davemloft.net>
References: <20090513230924.11416.68752.stgit@localhost.localdomain>
	<20090513231216.11416.9332.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	yi.zou@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090513231216.11416.9332.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 13 May 2009 16:12:16 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> This adds FCoE related statistics to 82599, including number Rx-ed and Tx-ed
> FCoE packets, number of Rx-ed and Tx-ed FCoE packets in dwords, number of bad
> Fiber Channel CRCs detected in FCoE packets, and number of FCoE packets dropped
> on the Rx side.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
