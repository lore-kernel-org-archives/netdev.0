From: David Miller <davem@davemloft.net>
Subject: Re: bnx2x fix for stable
Date: Mon, 09 Sep 2013 14:32:15 -0400 (EDT)
Message-ID: <20130909.143215.330174712108174504.davem@davemloft.net>
References: <1378749027.1806.4.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, davej@redhat.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753380Ab3IIScU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 14:32:20 -0400
In-Reply-To: <1378749027.1806.4.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 9 Sep 2013 18:50:27 +0100

> I think you need to either drop the bnx2x non-fix currently in your
> stable queue (commit c0a77ec74f29 'bnx2x: Add missing braces in
> bnx2x:bnx2x_link_initialize', or add the follow-up (commit 937e5c3d63a1
> 'bnx2x: Restore a call to config_init') with the net result of fixing
> indentation.

I know, I just ran into this while working on -stable submissions,
thanks Ben.
