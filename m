From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/4] ixgbe: Add support for 82599
 alternative WWNN/WWPN prefix
Date: Thu, 29 Oct 2009 01:04:38 -0700 (PDT)
Message-ID: <20091029.010438.11624755.davem@davemloft.net>
References: <20091029042339.15957.37676.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	linux-scsi@vger.kernel.org, yi.zou@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20091029042339.15957.37676.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 28 Oct 2009 21:23:57 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> The 82599 EEPROM supports alternative prefix for World Wide Node Name
> (WWNN) and World Wide Port Name (WWPN). The prefixes can be used together
> with the SAN MAC address to form the WWNN and WWPN, which can be used by
> upper layer drivers such as Fiber Channel over Ethernet (FCoE).
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
