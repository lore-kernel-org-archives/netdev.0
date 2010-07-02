From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: use NETIF_F_LRO
Date: Thu, 01 Jul 2010 22:50:37 -0700 (PDT)
Message-ID: <20100701.225037.254852643.davem@davemloft.net>
References: <20100701235811.16456.66115.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	sgruszka@redhat.com, donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49349
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756491Ab0GBFuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 01:50:24 -0400
In-Reply-To: <20100701235811.16456.66115.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 01 Jul 2010 16:58:25 -0700

> From: Stanislaw Gruszka <sgruszka@redhat.com>
> 
> Both ETH_FLAG_LRO and NETIF_F_LRO have the same value, but NETIF_F_LRO
> is intended to use with netdev->features.
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
