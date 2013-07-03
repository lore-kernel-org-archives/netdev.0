From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] alx: remove WoL support
Date: Wed, 03 Jul 2013 16:36:00 -0700 (PDT)
Message-ID: <20130703.163600.917400721588699099.davem@davemloft.net>
References: <1372880891-12320-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39317 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773Ab3GCXgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 19:36:04 -0400
In-Reply-To: <1372880891-12320-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed,  3 Jul 2013 21:48:11 +0200

> Unfortunately, WoL is broken and the system will immediately
> resume after suspending, and I can't seem to figure out why.
> Remove WoL support until the issue can be found.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied, thanks.
