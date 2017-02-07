From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: sr: fix non static symbol warnings
Date: Tue, 07 Feb 2017 11:43:26 -0500 (EST)
Message-ID: <20170207.114326.1434929420018473207.davem@davemloft.net>
References: <20170206161505.10457-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, weiyongjun1@huawei.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51368 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755447AbdBGQn2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 11:43:28 -0500
In-Reply-To: <20170206161505.10457-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon,  6 Feb 2017 16:15:05 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warnings:
> 
> net/ipv6/seg6_iptunnel.c:58:5: warning:
>  symbol 'nla_put_srh' was not declared. Should it be static?
> net/ipv6/seg6_iptunnel.c:238:5: warning:
>  symbol 'seg6_input' was not declared. Should it be static?
> net/ipv6/seg6_iptunnel.c:254:5: warning:
>  symbol 'seg6_output' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
