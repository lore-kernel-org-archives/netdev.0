From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] mlx4: make functions local and remove
 dead code.
Date: Sun, 24 Oct 2010 15:19:56 -0700 (PDT)
Message-ID: <20101024.151956.59657999.davem@davemloft.net>
References: <E113D394D7C5DB4F8FF691FA7EE9DB443CC3716F65@MTLMAIL.mtl.com>
	<20101021.031356.115939257.davem@davemloft.net>
	<20101021095920.17bd21f1@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, netdev@vger.kernel.org, eli@mellanox.co.il
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56835
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933030Ab0JXWTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 18:19:33 -0400
In-Reply-To: <20101021095920.17bd21f1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 21 Oct 2010 09:59:20 -0700

> Make the following function static: mlx4_UNMAP_ICM
> Remove the following unused function:  mlx4_MAP_ICM_page
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
