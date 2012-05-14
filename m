From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix incorrect ipsec transport mode fragment
Date: Mon, 14 May 2012 18:41:32 -0400 (EDT)
Message-ID: <20120514.184132.1506982467448756718.davem@davemloft.net>
References: <20120215104021.GC31660@secunet.com>
	<1336965660-14201-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20120514130528.GA24733@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, netdev@vger.kernel.org, lw@cn.fujitsu.com
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756759Ab2ENWlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 18:41:55 -0400
In-Reply-To: <20120514130528.GA24733@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 14 May 2012 15:05:28 +0200

> There might be other opinions, but I don't like to see this IPsec mode
> dependent stuff hacked into the generic ipv6 output path.

Completely agreed.
