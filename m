From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: better comments for RTO initiallization
Date: Wed, 04 Sep 2013 14:42:54 -0400 (EDT)
Message-ID: <20130904.144254.1400556228778253031.davem@davemloft.net>
References: <1378242875-5172-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932236Ab3IDSm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 14:42:58 -0400
In-Reply-To: <1378242875-5172-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Tue,  3 Sep 2013 14:14:35 -0700

> Commit 1b7fdd2ab585("tcp: do not use cached RTT for RTT estimation")
> removes important comments on how RTO is initialized and updated.
> Hopefully this patch puts those information back.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied.
