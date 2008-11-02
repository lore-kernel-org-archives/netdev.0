From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET-NEXT PATCH] ixgbe: add device support for 82598AT (copper
 10GbE)	adapters
Date: Sun, 02 Nov 2008 08:01:00 -0500
Message-ID: <490DA48C.90701@garzik.org>
References: <20081031074640.25760.45148.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57894 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753431AbYKBNBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Nov 2008 08:01:05 -0500
In-Reply-To: <20081031074640.25760.45148.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Intel is currently shipping support for adapters with a phy
> that does 10GBase-T (copper), which is 10 Gigabit ethernet
> over standard Category 6 cabling.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe.h         |    1 +
>  drivers/net/ixgbe/ixgbe_82598.c   |   12 +++++++
>  drivers/net/ixgbe/ixgbe_ethtool.c |   27 +++++++++++++++
>  drivers/net/ixgbe/ixgbe_main.c    |   33 ++++++++++++++++++
>  drivers/net/ixgbe/ixgbe_phy.c     |   68 +++++++++++++++++++++++++++++++++++++
>  drivers/net/ixgbe/ixgbe_phy.h     |    7 ++++
>  drivers/net/ixgbe/ixgbe_type.h    |    6 +++
>  7 files changed, 154 insertions(+), 0 deletions(-)

applied


