From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v3] ixgbe: disable MSI-X by default on
 certain Cisco adapters
Date: Tue, 27 Apr 2010 19:47:56 -0700 (PDT)
Message-ID: <20100427.194756.266098165.davem@davemloft.net>
References: <20100428024521.28991.37874.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	nicholasx.d.nunley@intel.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36322
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754050Ab0D1Crw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 22:47:52 -0400
In-Reply-To: <20100428024521.28991.37874.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Apr 2010 19:45:26 -0700

> From: Nick Nunley <nicholasx.d.nunley@intel.com>
> 
> Due to an errata in 82598 parts MSI-X needs to be disabled
> in certain ixgbe devices designed to transfer peer-to-peer
> traffic on the PCIe bus. This patch sets the default
> interrupt type to MSI rather than MSI-X for specific Cisco
> ixgbe adapters.
> 
> Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
> Acked-by: John Ronciak <john.ronciak@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
