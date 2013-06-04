From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mark netdev_create_hash __net_init
Date: Tue, 04 Jun 2013 16:47:52 -0700 (PDT)
Message-ID: <20130604.164752.1837315753050452381.davem@davemloft.net>
References: <7cbbda0ef5f9aef68eeb6553761e0b325102547f.1370241801.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: baruch@tkos.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab3FDXrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 19:47:53 -0400
In-Reply-To: <7cbbda0ef5f9aef68eeb6553761e0b325102547f.1370241801.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baruch Siach <baruch@tkos.co.il>
Date: Mon,  3 Jun 2013 09:43:55 +0300

> netdev_create_hash() is only called from netdev_init() which is marked
> __net_init.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

Applied, thanks.
