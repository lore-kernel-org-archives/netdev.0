From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/13] amd-xgbe: AMD XGBE driver updates
 2017-08-17
Date: Fri, 18 Aug 2017 16:31:37 -0700 (PDT)
Message-ID: <20170818.163137.47392007166160893.davem@davemloft.net>
References: <20170818140209.14804.94997.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34972 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751045AbdHRXbi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:31:38 -0400
In-Reply-To: <20170818140209.14804.94997.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Fri, 18 Aug 2017 09:02:09 -0500

> The following updates are included in this driver update series:
> 
> - Set the MDIO mode to clause 45 for the 10GBase-T configuration
> - Set the MII control width to 8-bits for speeds less than 1Gbps
> - Fix an issue to related to module removal when the devices are up
> - Fix ethtool statistics related to packet counting of TSO packets
> - Add support for device renaming
> - Add additional dynamic debug output for the PCS window calculation
> - Optimize reading of DMA channel interrupt enablement register
> - Add additional dynamic debug output about the hardware features
> - Add per queue Tx and Rx ethtool statistics
> - Add a macro to clear ethtool_link_ksettings modes
> - Convert the driver to use the ethtool_link_ksettings
> - Add support for VXLAN offload capabilities
> - Add additional ethtool statistics related to VXLAN
> 
> This patch series is based on net-next.

Series applied, thanks.
