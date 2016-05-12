From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gtp: put back reference to netns when not
 required anymore
Date: Thu, 12 May 2016 15:29:55 -0400 (EDT)
Message-ID: <20160512.152955.1810923716299565670.davem@davemloft.net>
References: <1463066191-20748-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59200 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932307AbcELT37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 15:29:59 -0400
In-Reply-To: <1463066191-20748-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 12 May 2016 17:16:31 +0200

> This patch fixes a netns leak.
> 
> Fixes: 93edb8c7f94f ("gtp: reload GTPv1 header after pskb_may_pull()")
> Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied.
