From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] mlx4_en: Fix cleanup flow on cq activation
Date: Mon, 27 Apr 2009 02:31:39 -0700 (PDT)
Message-ID: <20090427.023139.101381076.davem@davemloft.net>
References: <49EC859C.700@mellanox.co.il>
	<49F5539E.6030308@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39627
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752778AbZD0Jbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 05:31:46 -0400
In-Reply-To: <49F5539E.6030308@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 27 Apr 2009 09:41:34 +0300

> In case of mlx4_en_activate_cq() failure, the cleanup
> code would go to rx_err and try to disable unactivated rings.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
