From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/16] mlx4_en: driver updates
Date: Wed, 23 Mar 2011 12:26:12 -0700 (PDT)
Message-ID: <20110323.122612.229763242.davem@davemloft.net>
References: <4D89B13B.2010404@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59293
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756578Ab1CWTZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 15:25:33 -0400
In-Reply-To: <4D89B13B.2010404@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Wed, 23 Mar 2011 10:37:15 +0200

> Hello David,
> 
> This is the second round for patches originally sent on March 07.
> 
> Changes from previous round (after getting the feedbacks):
> 1. Renamed IRQ name for TX rings.
> 2. Changed error message when failing to map BlueFlame area.
> 3. Removed drivers/infiniband/hw/mlx4/ parts of steering changes, those need to be applied with Raw QP support.

Series applied to net-2.6, thanks.
