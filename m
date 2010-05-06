From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] ixgbe: Remove unneeded register
 writes in VF VLAN setup
Date: Thu, 06 May 2010 00:32:10 -0700 (PDT)
Message-ID: <20100506.003210.45888959.davem@davemloft.net>
References: <20100506055703.8482.16515.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57720
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752934Ab0EFHcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:32:04 -0400
In-Reply-To: <20100506055703.8482.16515.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 05 May 2010 22:57:10 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> The driver is unnecessarily writing values to VLAN control registers.
> These writes already done elsewhere and are superfluous here.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
