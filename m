From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: add missing free_netdev() on error in
 qlge_probe()
Date: Sat, 25 May 2013 21:24:40 -0700 (PDT)
Message-ID: <20130525.212440.1908370880286054476.davem@davemloft.net>
References: <CAPgLHd-8NxBN2-x2zzjgbVNj4E_4bhVqdTi1HmxMh5pawXPKZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shahed.shaikh@qlogic.com, jitendra.kalsaria@qlogic.com,
	ron.mercer@qlogic.com, yongjun_wei@trendmicro.com.cn,
	linux-driver@qlogic.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774Ab3EZEYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 00:24:41 -0400
In-Reply-To: <CAPgLHd-8NxBN2-x2zzjgbVNj4E_4bhVqdTi1HmxMh5pawXPKZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 23 May 2013 17:09:50 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Add the missing free_netdev() before return from function
> qlge_probe() in the error handling case.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
