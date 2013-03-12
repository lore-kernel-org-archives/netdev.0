From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bridge: using for_each_set_bit to simplify the
 code
Date: Tue, 12 Mar 2013 08:15:51 -0400 (EDT)
Message-ID: <20130312.081551.319925705055312654.davem@davemloft.net>
References: <CAPgLHd_viA9nTBMRhhE-XJzYHu8a7f5Xjve9hYpU-RaY=uE9+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, yongjun_wei@trendmicro.com.cn,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755355Ab3CLMPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 08:15:39 -0400
In-Reply-To: <CAPgLHd_viA9nTBMRhhE-XJzYHu8a7f5Xjve9hYpU-RaY=uE9+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 11 Mar 2013 23:45:23 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Using for_each_set_bit() to simplify the code.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
