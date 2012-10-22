From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/14] be2net updates
Date: Sun, 21 Oct 2012 22:20:58 -0400 (EDT)
Message-ID: <20121021.222058.240748828558634755.davem@davemloft.net>
References: <158bb887-7f4c-4d3d-abc3-c5cb50c06edb@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: padmanabh.ratnakar@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55282 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932777Ab2JVCU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 22:20:59 -0400
In-Reply-To: <158bb887-7f4c-4d3d-abc3-c5cb50c06edb@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Date: Sat, 20 Oct 2012 21:31:05 +0530

> Padmanabh Ratnakar (14):
>   be2net: Fix driver load failure for different FW configs in Lancer
>   be2net: Fix setting QoS for VF for Lancer
>   be2net: Fix change MAC operation for VF for Lancer
>   be2net: Wait till resources are available for VF in error recovery
>   be2net: Fix configuring VLAN for VF for Lancer
>   be2net: Fix error messages while driver load for VFs
>   be2net: Fix ethtool get_settings output for VF
>   be2net: Fix issues in error recovery due to wrong queue state
>   be2net: Fix unnecessary delay in PCI EEH
>   be2net: Fix VF driver load on newer Lancer FW
>   be2net: Enabling Wake-on-LAN is not supported in S5 state
>   be2net: Fix FW flashing on Skyhawk-R
>   be2net: Fix skyhawk VF PCI Device ID
>   be2net: Update driver version

Series applied.
