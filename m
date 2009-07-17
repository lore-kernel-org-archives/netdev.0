From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] ixgbe: clear mac address data block in DCB
 mode
Date: Thu, 16 Jul 2009 18:10:57 -0700 (PDT)
Message-ID: <20090716.181057.35555606.davem@davemloft.net>
References: <20090716234303.23595.85275.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, lucy.liu@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43301
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933902AbZGQBKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 21:10:53 -0400
In-Reply-To: <20090716234303.23595.85275.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 16 Jul 2009 16:43:10 -0700

> This change clears the address data block memory space, which is needed for
> the 82598 which does not have a SAN MAC.
> 
> Signed-off-by: Lucy Liu <lucy.liu@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
