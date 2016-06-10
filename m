From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 00/13] Mellanox 100G mlx5 fixes for 4.7-rc
Date: Thu, 09 Jun 2016 22:06:43 -0700 (PDT)
Message-ID: <20160609.220643.1184823601138840003.davem@davemloft.net>
References: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbcFJFGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 01:06:47 -0400
In-Reply-To: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Fri, 10 Jun 2016 00:07:27 +0300

> The following series provides some small fixes for mlx5 driver.
> 
> Two small fixes for the mlx5e netdev, the 1st is for the blue flame 
> quota accounting and the 2nd is a small refactoring in shutdown flow.
> 
> Five trivial fixes for mlx5 E-Switch.
> 	- Allmulti mc_promisc flag was not set in a specific flow.
> 	- Modify VF node guid when admin mac is changed.
> 	- Race in vport enable flow.
> 	- Misc code fixes (kvfree when needed and error pointers checking).
> 	
> Three in mlx5 steering area.  Correct capabilities checking and root flow table update.
> 
> Three misc fixes in mlx5 commands enum and layouts.

Series applied, thanks.
