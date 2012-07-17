From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND] lpc_eth: remove duplicated include
Date: Mon, 16 Jul 2012 22:17:01 -0700 (PDT)
Message-ID: <20120716.221701.1650790983680631705.davem@davemloft.net>
References: <50040911.5050107@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: djduanjiong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754273Ab2GQFRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:17:02 -0400
In-Reply-To: <50040911.5050107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <djduanjiong@gmail.com>
Date: Mon, 16 Jul 2012 20:29:05 +0800

> Remove duplicated #include <linux/delay.h> in
> drivers/net/ethernet/nxp/lpc_eth.c
> 
> Signed-off-by: Duan Jiong<djduanjiong@gmail.com>

Applied, thanks.
