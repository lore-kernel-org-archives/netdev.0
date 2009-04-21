From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] mlx4_en: Assign dummy event handler for TX queue
Date: Tue, 21 Apr 2009 01:50:02 -0700 (PDT)
Message-ID: <20090421.015002.210656049.davem@davemloft.net>
References: <49EC859C.700@mellanox.co.il>
	<49EC86EB.1000004@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43173
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755400AbZDUIuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 04:50:10 -0400
In-Reply-To: <49EC86EB.1000004@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 20 Apr 2009 17:30:03 +0300

> The low level driver always assumes this handler exists.
> The lack of it could cause kernel panic
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
