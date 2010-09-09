From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 4/4] drivers/net/ixgbe/ixgbe_main.c: Add
 ixgbe_psum
Date: Wed, 08 Sep 2010 21:41:57 -0700 (PDT)
Message-ID: <20100908.214157.57477079.davem@davemloft.net>
References: <20100908073229.722.61015.stgit@localhost.localdomain>
	<20100908073537.722.18896.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	joe@perches.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58609
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751374Ab0IIElk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 00:41:40 -0400
In-Reply-To: <20100908073537.722.18896.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 08 Sep 2010 00:35:40 -0700

> From: Joe Perches <joe@perches.com>
> 
> Reduce indentation in a couple of places
> Add static function ixgbe_psum
> Add temporary for adapter->stats
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
