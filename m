From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: don't call addrconf_dst_alloc again when enable lo
Date: Fri, 17 Jan 2014 05:09:18 +0100
Message-ID: <20140117040918.GA26022@order.stressinduktion.org>
References: <20140102065429.GB22494@order.stressinduktion.org> <52C51C1E.9040603@huawei.com> <20140102082325.GC22494@order.stressinduktion.org> <52C5325B.8020900@huawei.com> <20140103065349.GK22494@order.stressinduktion.org> <52CD0331.8040204@cn.fujitsu.com> <20140108080528.GD9007@order.stressinduktion.org> <52CD0F86.30605@cn.fujitsu.com> <20140108085554.GF9007@order.stressinduktion.org> <52D88F29.5010404@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Gao feng <gaofeng@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>, kumaran.4353@gmail.com,
	netdev@vger.kernel.org
To: chenweilong <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44500 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbaAQEJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 23:09:20 -0500
Content-Disposition: inline
In-Reply-To: <52D88F29.5010404@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 10:02:17AM +0800, chenweilong wrote:
> It's quite a long time, How's your patch going on?

I apologize, it has gotten a bit off my radar lately, but I have the branch
still around and will resurrect it asap. I think it is a problem which really
should be solved.

Thanks,

  Hannes
