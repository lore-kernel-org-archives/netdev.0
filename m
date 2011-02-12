From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/15] be2net: patch series
Date: Fri, 11 Feb 2011 21:15:37 -0800 (PST)
Message-ID: <20110211.211537.179947855.davem@davemloft.net>
References: <20110211233215.GA18258@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajit.khaparde@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51565
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751097Ab1BLFPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Feb 2011 00:15:01 -0500
In-Reply-To: <20110211233215.GA18258@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>
Date: Fri, 11 Feb 2011 17:32:15 -0600

> Patch series for the be2net driver.
> 
> [01/15]: While configuring QOS for VF, pass proper domain id
> [02/15]: endianness fix in be_cmd_set_qos().
> [03/15]: Use domain id when be_cmd_if_destroy is called.
> [04/15]: Initialize and cleanup sriov resources only if pci_enable_sriov has succeeded.
> [05/15]: call be_vf_eth_addr_config() after register_netdev
> [06/15]: Cleanup the VF interface handles
> [07/15]: For the VF MAC, use the OUI from current MAC address
> [08/15]: pass domain numbers for pmac_add/del functions
> [09/15]: Allow VFs to call be_cmd_reset_function.
> [10/15]: Fix broken priority setting when vlan tagging is enabled.
> [11/15]: pass proper hdr_size while flashing redboot.
> [12/15]: fix be_suspend/resume/shutdown
> [13/15]: gracefully handle situations when UE is detected
> [14/15]: detect a UE even when a interface is down.
> [15/15]: restrict WOL to PFs only.
> 
> Please Apply.

All applied, thanks.
