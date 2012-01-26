From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Thu, 26 Jan 2012 13:49:13 -0500 (EST)
Message-ID: <20120126.134913.1527199339049684070.davem@davemloft.net>
References: <1327562515-29664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33578 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865Ab2AZStR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 13:49:17 -0500
In-Reply-To: <1327562515-29664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 25 Jan 2012 23:21:43 -0800

> The following are changes since commit e55684fadbc5c9c69cad1b3bae228c8374b99b85:
>   infiniband: nes: Convert nes_addr_resolve_neigh() over to dst_neigh_lookup().
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
> 
>   e1000e: cleanup Rx checksum offload code
>   e1000e: add Receive Packet Steering (RPS) support
>   e1000e: re-enable alternate MAC address for all devices which support
>     it
>   e1000e: convert head, tail and itr_register offsets to __iomem
>     pointers
>   e1000e: pass pointer to ring struct instead of adapter struct
>   e1000e: re-factor ethtool get/set ring parameter
>   e1000e: default IntMode based on kernel config & available hardware
>     support
>   e1000e: always set transmit descriptor control registers the same
>   e1000e: 82579: workaround for link drop issue
>   e1000e: use default settings for Tx Inter Packet Gap timer
>   e1000e: use hardware default values for Transmit Control register
>   e1000e: 82574/82583 Tx hang workaround

Pulled, thanks Jeff.
