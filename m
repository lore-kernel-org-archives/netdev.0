From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9 V2] mlx4_en: Verify number of RX rings doesn't
 exceed MAX_RX_RINGS
Date: Mon, 29 Dec 2008 18:38:32 -0800 (PST)
Message-ID: <20081229.183832.211942137.davem@davemloft.net>
References: <49589EDF.9040803@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, rdreier@cisco.com, netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41806
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752019AbYL3Ci3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 21:38:29 -0500
In-Reply-To: <49589EDF.9040803@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 29 Dec 2008 11:56:47 +0200

> Required in cases were dev->caps.num_comp_vectors > MAX_RX_RINGS.
> For current values this would happen on machines that have more
> then 16 cores.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
