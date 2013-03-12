From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bridge: using for_each_set_bit_from to simplify
 the code
Date: Tue, 12 Mar 2013 08:15:41 -0400 (EDT)
Message-ID: <20130312.081541.766514637621179783.davem@davemloft.net>
References: <CAPgLHd_EW_y3VjSc9F4+fgmHpPVLZsysBo+sdDambZN96WBBcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, yongjun_wei@trendmicro.com.cn,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932534Ab3CLMP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 08:15:28 -0400
In-Reply-To: <CAPgLHd_EW_y3VjSc9F4+fgmHpPVLZsysBo+sdDambZN96WBBcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 11 Mar 2013 23:43:48 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Using for_each_set_bit_from() to simplify the code.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
