From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/2] ixgbe: Fix KR to KX fail over for
 Mezzanine cards
Date: Thu, 08 Oct 2009 23:00:57 -0700 (PDT)
Message-ID: <20091008.230057.01329023.davem@davemloft.net>
References: <20091009013530.13495.97717.stgit@localhost.localdomain>
	<20091009013621.13495.66152.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, don.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55613
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755829AbZJIGBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 02:01:02 -0400
In-Reply-To: <20091009013621.13495.66152.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 08 Oct 2009 18:36:22 -0700

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> This patch allows the recently added backplane device IDs that support KR
> to fail over to KX during link setup.  This is accomplished by the new MAC
> link setup function ixgbe_setup_mac_link_smartspeed().  Comments were also
> updated to better document the reason for the delays chosen for KX, KX4, BX,
> BX4 and KR connections.
> 
> Signed-off-by: Don Skidmore <don.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
