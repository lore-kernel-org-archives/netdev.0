From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rocker: fix error return code in rocker_probe()
Date: Thu, 16 Apr 2015 12:13:54 -0400 (EDT)
Message-ID: <20150416.121354.942885225704123099.davem@davemloft.net>
References: <1429186862-20989-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, sfeldma@gmail.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296AbbDPQN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:13:56 -0400
In-Reply-To: <1429186862-20989-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Thu, 16 Apr 2015 20:21:02 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return -EINVAL from the invalid PCI region size error
> handling case instead of 0, as done elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
