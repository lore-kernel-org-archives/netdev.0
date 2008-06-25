From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [UPDATED] ixgbe: add LRO support
Date: Tue, 24 Jun 2008 23:09:33 -0400
Message-ID: <4861B6ED.1010903@garzik.org>
References: <20080618222715.7333.59688.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, randy.dunlap@oracle.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48120 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756714AbYFYDJh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 23:09:37 -0400
In-Reply-To: <20080618222715.7333.59688.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> Support for in-kernel LRO with the ability to enable/disable via ethtool
> based on comments from Ben Hutchings.
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> ---
> 
>  drivers/net/Kconfig               |    3 +
>  drivers/net/ixgbe/ixgbe.h         |    9 +++
>  drivers/net/ixgbe/ixgbe_ethtool.c |   11 ++++
>  drivers/net/ixgbe/ixgbe_main.c    |  111 ++++++++++++++++++++++++++++++-------
>  4 files changed, 112 insertions(+), 22 deletions(-)

applied


