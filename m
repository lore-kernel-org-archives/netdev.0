From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] tcp: mitigate TCP ACK loops due to
 out-of-window validation dupacks
Date: Sun, 08 Feb 2015 01:03:44 -0800 (PST)
Message-ID: <20150208.010344.1335512084515113979.davem@davemloft.net>
References: <1423256681-31716-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755762AbbBHJDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 04:03:45 -0500
In-Reply-To: <1423256681-31716-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Fri,  6 Feb 2015 16:04:37 -0500

> This patch series mitigates "ack loop" DoS scenarios by rate-limiting
> outgoing duplicate ACKs sent in response to incoming "out of window"
> segments.

Series applied, thanks a lot Neal.
