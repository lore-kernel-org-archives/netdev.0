From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] mlx4_en: Fix a kernel panic when waking tx
 queue
Date: Mon, 25 May 2009 01:44:35 -0700 (PDT)
Message-ID: <20090525.014435.203274473.davem@davemloft.net>
References: <4A0AB34A.10100@mellanox.co.il>
	<4A1948D7.8010504@mellanox.co.il>
	<4A1A57AA.1080209@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39695
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754797AbZEYIog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 04:44:36 -0400
In-Reply-To: <4A1A57AA.1080209@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 25 May 2009 11:32:42 +0300

> This patch fixes a kernel panic when waking the TX queue
> from irq context.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Why does it fix a panic?  What does the panic look like?
What causes it?

Commit message is way too terse, please fix this and resubmit.
