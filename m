From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Fix some multiqueue TUN problems
Date: Mon, 14 Jan 2013 18:17:10 -0500 (EST)
Message-ID: <20130114.181710.700870251868852657.davem@davemloft.net>
References: <20130114170837.31874.78897.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35545 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757043Ab3ANXRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 18:17:12 -0500
In-Reply-To: <20130114170837.31874.78897.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Mon, 14 Jan 2013 12:12:06 -0500

> No significant changes to this patchset since the last posting, just a
> slight merge with the recent changes in tun_set_queue() and some
> Acked-by and Tested-by additions.  I believe all the concerns have been
> addressed and this patch is ready for merging.
> 
> Dave, I think it makes the most sense for this to get pulled in via the
> netdev tree but if you think otherwise let me know and I'll go bug
> James and Eric.

Series applied, thanks Paul.
