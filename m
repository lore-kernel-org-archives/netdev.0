From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] include/linux/skbuff.h: move CONFIG_XFRM
 check inside the skb_sec_path()
Date: Wed, 02 Oct 2013 16:50:50 -0400 (EDT)
Message-ID: <20131002.165050.964821248969345193.davem@davemloft.net>
References: <1380679112-2393-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49246 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753552Ab3JBUuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 16:50:51 -0400
In-Reply-To: <1380679112-2393-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Wed,  2 Oct 2013 05:58:32 +0400

> And thus we have only one function definition
> 
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> ---
> v1->v2: rebase to net-next head

Applied, thanks.
