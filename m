From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] drivers: irda: fix sign bug
Date: Thu, 15 Jul 2010 20:28:23 -0700 (PDT)
Message-ID: <20100715.202823.200354925.davem@davemloft.net>
References: <1279219494-12408-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, samuel@sortiz.org,
	kuninori.morimoto.gx@renesas.com, netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38411
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935496Ab0GPD2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 23:28:07 -0400
In-Reply-To: <1279219494-12408-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Thu, 15 Jul 2010 22:44:54 +0400

> platform_get_irq_byname() can return negative results, it is not seen to
> unsigned irq. Make it signed.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied.
