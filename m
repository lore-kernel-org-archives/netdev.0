From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] igbvf, ixgbevf: use dev_hw_addr_random
Date: Tue, 27 Jul 2010 13:18:36 -0700 (PDT)
Message-ID: <20100727.131836.232892891.davem@davemloft.net>
References: <4C4EA5E2.1050909@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, gregory.v.rose@intel.com
To: sassmann@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53908
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751853Ab0G0UST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 16:18:19 -0400
In-Reply-To: <4C4EA5E2.1050909@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@redhat.com>
Date: Tue, 27 Jul 2010 11:24:50 +0200

> From: Stefan Assmann <sassmann@redhat.com>
> 
> Both igbvf and ixgbevf should set addr_assign_type to NET_ADDR_RANDOM
> so udev creates persistent net rules by matching the device path.
> Do this by using the dev_hw_addr_random helper function.
> 
> Signed-off-by: Stefan Assmann <sassmann@redhat.com>

Applied.
