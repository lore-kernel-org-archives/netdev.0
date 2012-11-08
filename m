From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] ksz884x: use module_pci_driver to simplify the
 code
Date: Wed, 07 Nov 2012 19:01:40 -0500 (EST)
Message-ID: <20121107.190140.1862649158439289219.davem@davemloft.net>
References: <CAPgLHd8mrDXyiJ4rNFLHsYWEreVRiKXwqqr7umtSY36RkzXjUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753461Ab2KHABm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 19:01:42 -0500
In-Reply-To: <CAPgLHd8mrDXyiJ4rNFLHsYWEreVRiKXwqqr7umtSY36RkzXjUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 7 Nov 2012 20:54:30 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Use the module_pci_driver() macro to make the code simpler
> by eliminating module_init and module_exit calls.
> 
> dpatch engine is used to auto generate this patch.
> (https://github.com/weiyj/dpatch)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.
