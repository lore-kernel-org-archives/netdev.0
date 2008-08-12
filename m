From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Please pull updates for IPVS
Date: Mon, 11 Aug 2008 18:10:19 -0700 (PDT)
Message-ID: <20080811.181019.190669302.davem@davemloft.net>
References: <alpine.LNX.1.10.0808112318510.12259@titan.stealer.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	horms@verge.net.au
To: sven.wegener@stealer.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59585
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750975AbYHLBKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 21:10:18 -0400
In-Reply-To: <alpine.LNX.1.10.0808112318510.12259@titan.stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Wegener <sven.wegener@stealer.net>
Date: Mon, 11 Aug 2008 23:46:50 +0200 (CEST)

> I have a couple of updates for IPVS pending. The patches have been
> posted to the mailing-list and acked by Simon Horman, so I thought it's
> ok to send you a pull request for them, if that's ok with you.
> 
> Mostly trivial cleanups. Two potential deadlock fixes, one introduced by
> my last sync daemon changes and one in the estimator code, which is
> going back for years. The other estimator change is the biggest one. If
> you have an issue with something, just holler and I'll get on it. I'll
> append an overall diff as it's not that big.

Pulled, thanks a lot Sven.
