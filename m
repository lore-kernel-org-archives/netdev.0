From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] caif_virtio: fix error return code in
 cfv_create_genpool()
Date: Fri, 22 Mar 2013 10:24:25 -0400 (EDT)
Message-ID: <20130322.102425.1728735565421860819.davem@davemloft.net>
References: <CAPgLHd-VdCq3qfDGYpCE1VmPeHGFneyR3TaarS=bMROqWmj2uA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, rusty@rustcorp.com.au,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932925Ab3CVOY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 10:24:27 -0400
In-Reply-To: <CAPgLHd-VdCq3qfDGYpCE1VmPeHGFneyR3TaarS=bMROqWmj2uA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Fri, 22 Mar 2013 21:16:52 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return a negative error code from the error handling
> case instead of 0, as returned elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/caif/caif_virtio.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

I can't apply this as this file doesn't exist in my tree.
