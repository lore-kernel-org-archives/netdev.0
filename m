From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 0/3] ipv6: tcp_ipv6 policy route issue
Date: Mon, 31 Mar 2014 16:16:45 -0400 (EDT)
Message-ID: <20140331.161645.1420318621069166291.davem@davemloft.net>
References: <1396056451-5600-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: wangyufen@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbaCaUQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 16:16:48 -0400
In-Reply-To: <1396056451-5600-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wangyufen <wangyufen@huawei.com>
Date: Sat, 29 Mar 2014 09:27:28 +0800

> From: Wang Yufen <wangyufen@huawei.com>
> 
> Wang Yufen (3):
>   ipv6: tcp_ipv6 do some cleanup
>   ipv6: reuse rt6_need_strict
>   ipv6: tcp_ipv6 policy route issue
> 
> v4: use rt6_need_strict to check whether the oif directly
>     assigned to iif
> v5: Move the whole rt6_need_strict as static inline into 
>     ip6_route.h, instade of just delete static.

Series applied, thanks.
