From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] mlx4_en: Move to SW counters for total bytes and
 packets
Date: Tue, 21 Apr 2009 01:50:12 -0700 (PDT)
Message-ID: <20090421.015012.120347162.davem@davemloft.net>
References: <49EC859C.700@mellanox.co.il>
	<49EC87AB.1070009@mellanox.co.il>
	<49EC87FE.4010000@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43179
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756023AbZDUIuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 04:50:20 -0400
In-Reply-To: <49EC87FE.4010000@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 20 Apr 2009 17:34:38 +0300

> The per ring counters are implemented in SW. Now moving to have the total
> counters as the sum of all rings. This way the numbers will always be consistent
> and we no longer depend on HW buffer size limitations for those counters
> that can be insufficient in some cases.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
