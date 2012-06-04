From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/9p: Add __force to cast of __user pointer
Date: Mon, 04 Jun 2012 14:12:09 -0400 (EDT)
Message-ID: <20120604.141209.2031940968411630289.davem@davemloft.net>
References: <4b3738493b23bc386d3372012faa8cd3672a138d.1338780551.git.joe@perches.com>
	<1338825881.3979.203.camel@deadeye>
	<1338830174.15683.2.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753514Ab2FDSML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 14:12:11 -0400
In-Reply-To: <1338830174.15683.2.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 04 Jun 2012 10:16:14 -0700

> A recent commit that removed unnecessary casts of pointers
> to the same type uncovered a missing __force cast.
> 
> Add it.
> 
> Reported by: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
