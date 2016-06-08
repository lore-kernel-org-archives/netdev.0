From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: record TLP and ER timer stats in v6 stats
Date: Tue, 07 Jun 2016 17:13:24 -0700 (PDT)
Message-ID: <20160607.171324.828826151768554568.davem@davemloft.net>
References: <1465250838-13731-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nanditad@google.com, ncardwell@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59259 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753661AbcFHAN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 20:13:26 -0400
In-Reply-To: <1465250838-13731-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon,  6 Jun 2016 15:07:18 -0700

> The v6 tcp stats scan do not provide TLP and ER timer information
> correctly like the v4 version . This patch fixes that.
> 
> Fixes: 6ba8a3b19e76 ("tcp: Tail loss probe (TLP)")
> Fixes: eed530b6c676 ("tcp: early retransmit")
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied and queued up for -stable, thanks.
