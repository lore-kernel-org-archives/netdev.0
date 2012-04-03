From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] TCP: update ip_local_port_range documentation
Date: Tue, 03 Apr 2012 17:40:37 -0400 (EDT)
Message-ID: <20120403.174037.1557770873488371175.davem@davemloft.net>
References: <20120403200834.witdp0frwwo48occ@webmail.int.intellilink.co.jp>
	<20120403201221.ovff4aabtwwcoco0@webmail.int.intellilink.co.jp>
	<20120404034140.9qatex0wg8ccok4o@webmail.int.intellilink.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: fernando@intellilink.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755073Ab2DCVkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 17:40:45 -0400
In-Reply-To: <20120404034140.9qatex0wg8ccok4o@webmail.int.intellilink.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fernando@intellilink.co.jp
Date: Wed,  4 Apr 2012 03:41:40 +0900

> I forgot to add my Signed-off-by and the patch explanation.
> I am aosrry for the noise. Updated patch attached.

Since you put this at the top of the message body, I had to
edit it out of the patch submission by hand.

Your commit message proper needed to be edited by hand as well
because there were missing spaces between the Documentation
file path and the word that came right afterwards.

Furthermore, you had trailing whitespace in your patch, which I also
had to fix up by hand.

You know, this wasn't exactly a rocket-science patch, I spent more
time fixing up your patch than I would have spend implementing
the patch myself.  That is _never_ a good sign.
