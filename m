From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] sctp: fix error return code in sctp_init()
Date: Tue, 14 Jun 2016 23:46:00 -0700 (PDT)
Message-ID: <20160614.234600.2262103276628303309.davem@davemloft.net>
References: <1465830506-22752-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
	yongjun_wei@trendmicro.com.cn, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752780AbcFOGqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 02:46:02 -0400
In-Reply-To: <1465830506-22752-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Mon, 13 Jun 2016 23:08:26 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return a negative error code from the error handling
> case instead of 0, as done elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
