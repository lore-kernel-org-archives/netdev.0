From: David Miller <davem@davemloft.net>
Subject: Re: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Wed, 06 Jun 2012 13:17:03 -0700 (PDT)
Message-ID: <20120606.131703.870120997635192180.davem@davemloft.net>
References: <jqo7op$t6f$1@dough.gmane.org>
	<20120606.115130.1091814494251887552.davem@davemloft.net>
	<jqo9ej$ao4$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: grant.b.edwards@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38813 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938Ab2FFURG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 16:17:06 -0400
In-Reply-To: <jqo9ej$ao4$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Edwards <grant.b.edwards@gmail.com>
Date: Wed, 6 Jun 2012 19:01:40 +0000 (UTC)

> That's what I'll do as soon as I can find a definition of what the API
> for alloc_skb() actually _is_.  It has clearly changed in the past few
> years.

And it will continue to change.  There are no stable APIs inside of
the kernel, none.
