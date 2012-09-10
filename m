From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif: move the dereference below the NULL test
Date: Mon, 10 Sep 2012 16:14:07 -0400 (EDT)
Message-ID: <20120910.161407.1806703127621226080.davem@davemloft.net>
References: <CAPgLHd-MBQnrU9tS0VFw-O7yvs47r3waHqGm1SRS4GA72Pn1hg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626Ab2IJUOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 16:14:11 -0400
In-Reply-To: <CAPgLHd-MBQnrU9tS0VFw-O7yvs47r3waHqGm1SRS4GA72Pn1hg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 10 Sep 2012 12:38:27 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> The dereference should be moved below the NULL test.
> 
> spatch with a semantic match is used to found this.
> (http://coccinelle.lip6.fr/)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.
