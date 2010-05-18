From: David Miller <davem@davemloft.net>
Subject: bug fixes only please...
Date: Mon, 17 May 2010 22:25:49 -0700 (PDT)
Message-ID: <20100517.222549.149852932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52032
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754961Ab0ERFZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:25:41 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3936924C090
	for <netdev@vger.kernel.org>; Mon, 17 May 2010 22:25:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We are entering the merge window, so please do not submit any new
features or cleanups at this time.

I will make a final pass through patchwork before I submit to Linus
so anything there still has a chance.  I also plan to merge the
respun virtif netlink bits, as that code was ready it's just that
a change that went into net-2.6 the other day created conflicts.

We'll open the spigot back up after 2.6.35-rc1 goes out.

Thanks.
