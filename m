From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cavium: change NET_VENDOR_CAVIUM to bool
Date: Wed, 21 Oct 2015 19:12:40 -0700 (PDT)
Message-ID: <20151021.191240.1732004811299642255.davem@davemloft.net>
References: <mvmy4eyq386.fsf@hawking.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: schwab@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754852AbbJVB4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 21:56:14 -0400
In-Reply-To: <mvmy4eyq386.fsf@hawking.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Schwab <schwab@suse.de>
Date: Mon, 19 Oct 2015 17:37:13 +0200

> CONFIG_NET_VENDOR_CAVIUM is only used to hide/show config options and to
> include subdirectories in the build, so it doesn't make sense to make it
> tristate.
> 
> Signed-off-by: Andreas Schwab <schwab@suse.de>

Applied, thanks.
