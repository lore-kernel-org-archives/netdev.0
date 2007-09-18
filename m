From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Mon, 17 Sep 2007 19:05:27 -0700 (PDT)
Message-ID: <20070917.190527.42775386.davem@davemloft.net>
References: <20070828.142216.99461544.davem@davemloft.net>
	<1188598563.6062.191.camel@localhost>
	<1189798908.19708.170.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, jgarzik@pobox.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44241
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754583AbXIRCFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 22:05:32 -0400
In-Reply-To: <1189798908.19708.170.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Fri, 14 Sep 2007 12:41:48 -0700

> David?  Did you ever get a chance to look at this?
> Do you want me to rebase it against your newer net-2.4.26?
> 
> http://repo.or.cz/w/linux-2.6/trivial-mods.git

How can I pull from this tree?

davem@sunset:~/src/GIT/mac_fmt-2.6$ git pull http://repo.or.cz/w/linux-2.6/trivial-mods.git
error: pick-rref: HEAD not found
No such ref HEAD at http://repo.or.cz/w/linux-2.6/trivial-mods.git
davem@sunset:~/src/GIT/mac_fmt-2.6$ 

Anyways, it would indeed help if you could rebase the patch
against net-2.6.24  It would save me a ton of time.

Thanks!
