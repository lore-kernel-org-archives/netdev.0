From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/spider_net: fix error return code in
 spider_net_open()
Date: Wed, 08 May 2013 13:15:03 -0700 (PDT)
Message-ID: <20130508.131503.1942281191347393009.davem@davemloft.net>
References: <CAPgLHd9kSJdv+gdKr6OBcG2h0RmjnWFscELHGEPQwT1kbD5FSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kou.ishizaki@toshiba.co.jp, jens@de.ibm.com,
	grant.likely@linaro.org, rob.herring@calxeda.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755611Ab3EHUPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 16:15:05 -0400
In-Reply-To: <CAPgLHd9kSJdv+gdKr6OBcG2h0RmjnWFscELHGEPQwT1kbD5FSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 7 May 2013 20:16:00 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return a negative error code from the error handling
> case instead of 0, as done elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
