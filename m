From: David Miller <davem@davemloft.net>
Subject: Re: net-next warning at kernel/softirq.c:159 local_bh_enable
Date: Thu, 05 Jul 2012 21:20:42 -0700 (PDT)
Message-ID: <20120705.212042.1059058890336758924.davem@davemloft.net>
References: <alpine.LRH.2.00.1207060616590.21283@ogerlitz.voltaire.com>
	<alpine.LRH.2.00.1207060716390.32599@ogerlitz.voltaire.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shlomop@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237Ab2GFEUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 00:20:45 -0400
In-Reply-To: <alpine.LRH.2.00.1207060716390.32599@ogerlitz.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Fri, 6 Jul 2012 07:17:33 +0300

> FWIW - I've updated my net-next clone to the lastest and still
> see this, even after the IPv6 related fix.

I sent you the infiniband patch necessary for this bug.
