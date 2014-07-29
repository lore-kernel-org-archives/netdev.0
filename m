From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cdc-ether: clean packet filter upon probe
Date: Tue, 29 Jul 2014 12:22:40 -0700 (PDT)
Message-ID: <20140729.122240.1345069203114379976.davem@davemloft.net>
References: <1406537796-20156-1-git-send-email-oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbaG2TWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 15:22:41 -0400
In-Reply-To: <1406537796-20156-1-git-send-email-oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Mon, 28 Jul 2014 10:56:36 +0200

> There are devices that don't do reset all the way. So the packet filter should
> be set to a sane initial value. Failure to do so leads to intermittent failures
> of DHCP on some systems under some conditions.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

Applied.
