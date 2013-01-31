From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next 1/4] ipv6 flowlabel: Ensure to take lock when
 modifying np->ip6_sk_fl_list.
Date: Wed, 30 Jan 2013 22:41:23 -0500 (EST)
Message-ID: <20130130.224123.1804831027304940890.davem@davemloft.net>
References: <510973F2.3080400@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48434 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755496Ab3AaDlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 22:41:25 -0500
In-Reply-To: <510973F2.3080400@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 31 Jan 2013 04:26:42 +0900

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
