From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] sit: allow to use rtnl ops on fb tunnel
Date: Thu, 03 Oct 2013 13:37:29 -0400 (EDT)
Message-ID: <20131003.133729.1786820686494238068.davem@davemloft.net>
References: <524BCCE2.8000700@6wind.com>
	<20131002.170822.1627691739724018976.davem@davemloft.net>
	<524D2580.9040702@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	pshelar@nicira.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754288Ab3JCRhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 13:37:37 -0400
In-Reply-To: <524D2580.9040702@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 03 Oct 2013 10:06:24 +0200

> In fact, I just notice that 3.9 branch is EoL (bug is only in 3.8 and
> 3.9).
> Should I still send a patch ? If yes, based on which tree/branch?

No stable backports are needed then.
