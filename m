From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2 0/8] ipv6: clean up locking code in anycast
 and mcast
Date: Sat, 13 Sep 2014 16:39:10 -0400 (EDT)
Message-ID: <20140913.163910.2245929028634788806.davem@davemloft.net>
References: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	yoshfuji@linux-ipv6.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299AbaIMUjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 16:39:13 -0400
In-Reply-To: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 11 Sep 2014 15:35:08 -0700

> This patchset cleans up the locking code in anycast.c and mcast.c
> and makes the refcount code more readable.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> v1 -> v2:
> * refactor some code and make it in a separated patch
> * update comments

Series applied, thanks.
