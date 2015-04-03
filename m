From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net] ipv4: take rtnl_lock and mark mrt table as
 freed on namespace cleanup
Date: Thu, 02 Apr 2015 20:53:17 -0400 (EDT)
Message-ID: <20150402.205317.1230672883848850811.davem@davemloft.net>
References: <1427824907-13331-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021AbbDCAxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 20:53:19 -0400
In-Reply-To: <1427824907-13331-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 31 Mar 2015 11:01:45 -0700

> This is the IPv4 part for commit 905a6f96a1b1
> (ipv6: take rtnl_lock and mark mrt6 table as freed on namespace cleanup).
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
