From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ptp: use list_move instead of list_del/list_add
Date: Sun, 07 Oct 2012 14:53:44 -0400 (EDT)
Message-ID: <20121007.145344.2027626114354297185.davem@davemloft.net>
References: <CAPgLHd87UYDK7f=scccBq7AAO67=9pcg5CdKBG0+8i0kPFtXAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, bhutchings@solarflare.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44929 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957Ab2JGSxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 14:53:45 -0400
In-Reply-To: <CAPgLHd87UYDK7f=scccBq7AAO67=9pcg5CdKBG0+8i0kPFtXAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Sun, 7 Oct 2012 21:41:50 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Using list_move() instead of list_del() + list_add().
> 
> dpatch engine is used to auto generate this patch.
> (https://github.com/weiyj/dpatch)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
