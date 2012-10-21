From: David Miller <davem@davemloft.net>
Subject: Re: 3.5 bridging regression
Date: Sun, 21 Oct 2012 19:25:56 -0400 (EDT)
Message-ID: <20121021.192556.952646404147204428.davem@davemloft.net>
References: <20121021112727.GF21937@1wt.eu>
	<1350820413.13333.2042.camel@edumazet-glaptop>
	<20121021132610.GG21937@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54556 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932575Ab2JUXZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 19:25:58 -0400
In-Reply-To: <20121021132610.GG21937@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Sun, 21 Oct 2012 15:26:10 +0200

> David, are you OK with sending this patch for -stable ? It fixes
> a 3.5 regression causing bridge to panic.

Why do people ask me so many questions they can answer on their
own?

http://patchwork.ozlabs.org/user/bundle/2566/?state=*
