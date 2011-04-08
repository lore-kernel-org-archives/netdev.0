From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: Sensing link type at device initialization
Date: Thu, 07 Apr 2011 20:36:32 -0700 (PDT)
Message-ID: <20110407.203632.39178964.davem@davemloft.net>
References: <4D9D82DA.2090301@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47457
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757401Ab1DHDhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 23:37:08 -0400
In-Reply-To: <4D9D82DA.2090301@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 7 Apr 2011 12:24:42 +0300

> 
> When bringing the port up, performing a SENSE_PORT command
> To try and check to which physical link type (IB or Ethernet) the physical
> port is connected.
> In case there is no valid link partner, the port will come up as its
> supported default.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
