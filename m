From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] sock: remove skb argument from
 sk_rcvqueues_full
Date: Wed, 23 Jul 2014 13:23:42 -0700 (PDT)
Message-ID: <20140723.132342.2064565103466188898.davem@davemloft.net>
References: <1406053011-18645-1-git-send-email-sorin@returnze.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	sergei.shtylyov@cogentembedded.com
To: sorin@returnze.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933091AbaGWUXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 16:23:46 -0400
In-Reply-To: <1406053011-18645-1-git-send-email-sorin@returnze.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sorin Dumitru <sorin@returnze.ro>
Date: Tue, 22 Jul 2014 21:16:51 +0300

> It hasn't been used since commit 0fd7bac(net: relax rcvbuf limits).
> 
> Signed-off-by: Sorin Dumitru <sorin@returnze.ro>

Applied, thanks.
