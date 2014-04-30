From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ipv6: Introduce ip6_sk_dst_hoplimit.
Date: Wed, 30 Apr 2014 13:32:10 -0400 (EDT)
Message-ID: <20140430.133210.523793117846413657.davem@davemloft.net>
References: <1398740254-2356-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42196 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759256AbaD3RcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 13:32:12 -0400
In-Reply-To: <1398740254-2356-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Tue, 29 Apr 2014 11:57:34 +0900

> This replaces 6 identical code snippets with a call to a new
> static inline function.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied to net-next, thanks.
