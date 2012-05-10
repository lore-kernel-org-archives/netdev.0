From: David Miller <davem@davemloft.net>
Subject: Re: pull request: sfc 2012-05-09
Date: Wed, 09 May 2012 22:50:35 -0400 (EDT)
Message-ID: <20120509.225035.1411872258110932490.davem@davemloft.net>
References: <1336615595.2499.24.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668Ab2EJCuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 22:50:46 -0400
In-Reply-To: <1336615595.2499.24.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 10 May 2012 03:06:35 +0100

> The following changes since commit 477206a018f902895bfcd069dd820bfe94c187b1:
> 
>   r8169: fix unsigned int wraparound with TSO (2012-05-08 19:34:10 -0400)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.4
> 
> (commit 3132d2827d92c2ee47fdf4dbec75bba0a2f291cb)
> 
> This fixes a regression introduced since Linux 3.3 which will result in
> a crash on load in certain configurations.

Pulled, thanks Ben.
