From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: change tcp_syn_retries documentation
Date: Wed, 20 Jan 2016 18:55:23 -0800 (PST)
Message-ID: <20160120.185523.191018682217897009.davem@davemloft.net>
References: <34e957bf04e4742b1d6ea599ee1ea75349e6f1f2.1453277553.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40497 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964984AbcAUCzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 21:55:24 -0500
In-Reply-To: <34e957bf04e4742b1d6ea599ee1ea75349e6f1f2.1453277553.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed, 20 Jan 2016 16:12:33 +0800

> Documentation should be kept consistent with the code:
> 
>  static int tcp_syn_retries_max = MAX_TCP_SYNCNT;
>  #define MAX_TCP_SYNCNT          127
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
