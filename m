From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_netem: replace magic numbers with
 enumerate in get_loss_clg
Date: Mon, 17 Feb 2014 16:56:08 -0500 (EST)
Message-ID: <20140217.165608.337256145925129118.davem@davemloft.net>
References: <1392626901-15096-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51611 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbaBQV4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 16:56:10 -0500
In-Reply-To: <1392626901-15096-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Mon, 17 Feb 2014 16:48:21 +0800

> Replace two magic numbers which intialize clgstate::state.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---

Applied, thank you.
