From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] mlx4_en: Handle page allocation failure during
 receive
Date: Mon, 27 Apr 2009 02:31:45 -0700 (PDT)
Message-ID: <20090427.023145.168124718.davem@davemloft.net>
References: <49EC859C.700@mellanox.co.il>
	<49EC87AB.1070009@mellanox.co.il>
	<49F553F1.7010701@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39630
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752897AbZD0Jbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 05:31:52 -0400
In-Reply-To: <49F553F1.7010701@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 27 Apr 2009 09:42:57 +0300

> If we failed to allocate new fragments for receive buffer,
> the packet should be dropped and packets should be reused.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
