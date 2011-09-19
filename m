From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next 2011-09-19
Date: Mon, 19 Sep 2011 17:11:24 -0400 (EDT)
Message-ID: <20110919.171124.1877822329573878893.davem@davemloft.net>
References: <20110919203639.GF2608@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kerenl.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755169Ab1ISVMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 17:12:31 -0400
In-Reply-To: <20110919203639.GF2608@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 19 Sep 2011 16:36:39 -0400

> Here is another big batch of updates intended for 3.2 -- still
> clearing-out the backlog...
> 
> This round includes lots of updates to ath9k, b43, iwlagn, and rt2x00.
> Some cleanups go to mac80211, along with a number of mesh-mode fixes
> from Javier.
> 
> Please let me know if there are problems!

What about the iwl build failure reported by Eric Dumazet?

If that's not handled here, I want that fixed before we add even
more regressions :-)
