From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5]mlx4_en: Fix a race at restart task
Date: Tue, 21 Apr 2009 01:49:56 -0700 (PDT)
Message-ID: <20090421.014956.34933793.davem@davemloft.net>
References: <49EC859C.700@mellanox.co.il>
	<49EC85FD.2080009@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43170
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755710AbZDUIuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 04:50:04 -0400
In-Reply-To: <49EC85FD.2080009@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 20 Apr 2009 17:26:05 +0300

> The query whether the port is up or not should be done at
> the execution of the restart task and not when it is queued.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
