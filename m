From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Duplication of #define with mii.h.
Date: Fri, 26 Aug 2011 13:13:40 -0400 (EDT)
Message-ID: <20110826.131340.359166840254343380.davem@davemloft.net>
References: <20110825092019.GA21777@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38587 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934Ab1HZRNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 13:13:45 -0400
In-Reply-To: <20110825092019.GA21777@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 25 Aug 2011 11:20:19 +0200

> Please pull from branch 'davem-next.mii' in repository
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git davem-next.mii
> 
> to get the changes below.
> 
> The sunbmac changes are not compile tested. Sunbmac changeset is on top of the
> stack so it can be instantly removed if untrusted. Building a packaged rpm for a
> cross sparc-linux compiler quickly turned more interesting than expected.

I'll pull this and sanity check the build on sparc, thanks!
