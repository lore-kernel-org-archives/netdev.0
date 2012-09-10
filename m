From: David Miller <davem@davemloft.net>
Subject: Re: Who maintains and handles patches for drivers/net/phy/ ?
Date: Mon, 10 Sep 2012 04:02:20 -0400 (EDT)
Message-ID: <20120910.040220.405537912839670655.davem@davemloft.net>
References: <504D94AB.7070404@c-s.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christophe.leroy@c-s.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077Ab2IJICZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 04:02:25 -0400
In-Reply-To: <504D94AB.7070404@c-s.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leroy christophe <christophe.leroy@c-s.fr>
Date: Mon, 10 Sep 2012 09:20:11 +0200

> The MAINTAINER file doesn't include any maintainer for
> drivers/net/phy/
> Section NETWORKING DRIVERS doesn't refer to anyone.
> 
> I have a patch for the Intel LXT phy driver. I submitted it to the
> list a few weeks ago but didn't get any feedback at all.
> Who shall I contact to get my patch taken into account ?

Your comments were not formatted correctly so I tossed your patch
from the queue.  FOrmat comments:

	/* Like
	 * this.
	 */

not:

	/* Like
	 * this. */

and not:

	/* Like
	   this. */

Thanks.
