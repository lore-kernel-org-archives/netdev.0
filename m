From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 03/12] net: Add NETIF_F_FCOE_MTU to indicate
 support for a different MTU for FCoE
Date: Fri, 14 Aug 2009 16:12:50 -0700 (PDT)
Message-ID: <20090814.161250.27037810.davem@davemloft.net>
References: <20090814223857.1640.26881.stgit@localhost.localdomain>
	<20090814224156.1640.59034.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	gospo@redhat.com, yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090814224156.1640.59034.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 14 Aug 2009 15:41:57 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> Add NETIF_F_FCOE_MTU to indicate that the NIC can support a secondary MTU for
> converged traffic of LAN and Fiber Channel over Ethernet (FCoE). The MTU for
> FCoE is 2158 = 14 (FCoE header) + 24 (FC header) + 2112 (FC max payload) +
> 4 (FC CRC) + 4 (FCoE trailer).
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
