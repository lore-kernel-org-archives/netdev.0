From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ptp_pch: fix error handling in pch_probe()
Date: Sat, 25 May 2013 21:24:46 -0700 (PDT)
Message-ID: <20130525.212446.757591687610176020.davem@davemloft.net>
References: <CAPgLHd-ec4mveiMefnkSYLNnhYizt6_xZ7ZNLR9YxZCciMH+gA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188Ab3EZEYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 00:24:47 -0400
In-Reply-To: <CAPgLHd-ec4mveiMefnkSYLNnhYizt6_xZ7ZNLR9YxZCciMH+gA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 23 May 2013 17:59:28 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to release resources when ptp_clock_register() fail instead
> of return error code directly.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
