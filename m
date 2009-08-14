From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 02/12] ixgbe: updates vlan feature flags to
 enable FCoE offloads on vlan interface
Date: Fri, 14 Aug 2009 16:12:42 -0700 (PDT)
Message-ID: <20090814.161242.187642099.davem@davemloft.net>
References: <20090814223857.1640.26881.stgit@localhost.localdomain>
	<20090814224127.1640.84665.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	gospo@redhat.com, vasu.dev@intel.com, yi.zou@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47138
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932102AbZHNXMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 19:12:31 -0400
In-Reply-To: <20090814224127.1640.84665.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 14 Aug 2009 15:41:28 -0700

> From: Vasu Dev <vasu.dev@intel.com>
> 
> Updates netdev->vlan_features for NETIF_F_FCOE_CRC and NETIF_F_FSO, so that
> FCoE CRC and GSO offloads will get used for FCoE over ixgbe based vlan
> interface.
> 
> Signed-off-by: Vasu Dev <vasu.dev@intel.com>
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
