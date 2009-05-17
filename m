From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/8] ixgbe: Add FCoE feature header to
 82599
Date: Sun, 17 May 2009 13:58:01 -0700 (PDT)
Message-ID: <20090517.135801.11425762.davem@davemloft.net>
References: <20090513230924.11416.68752.stgit@localhost.localdomain>
	<20090513231001.11416.93927.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090513231001.11416.93927.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 13 May 2009 16:10:01 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> This adds the FCoE feature header ixgbe_fcoe.h to 82599. This header includes
> the defines and structures required by the ixgbe driver to support various
> offload features in 82599 for Fiber Channel over Ethernet (FCoE).  These offloads
> features include Fiber Channel CRC calculation, FCoE SOF/EOF auto insertion,
> FCoE Sequence Offload (FSO) for large send, and Direct Data Placement (DDP)
> for large receive.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
