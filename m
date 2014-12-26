From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] neigh: remove next ptr from struct neigh_table
Date: Fri, 26 Dec 2014 17:07:20 -0500 (EST)
Message-ID: <20141226.170720.694500620209004905.davem@davemloft.net>
References: <1419353437-4213-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbaLZWHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2014 17:07:22 -0500
In-Reply-To: <1419353437-4213-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 23 Dec 2014 17:50:37 +0100

> After commit
> d7480fd3b173 ("neigh: remove dynamic neigh table registration support"),
> this field is not used anymore.
> 
> CC: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thank you.
