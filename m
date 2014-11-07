From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cdc-ether: implement MULTICAST flag on the device
Date: Fri, 07 Nov 2014 15:19:42 -0500 (EST)
Message-ID: <20141107.151942.1445181916148574569.davem@davemloft.net>
References: <1415283554-27024-1-git-send-email-oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olivier.blin@softathome.com, netdev@vger.kernel.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459AbaKGUTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 15:19:45 -0500
In-Reply-To: <1415283554-27024-1-git-send-email-oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Thu,  6 Nov 2014 15:19:14 +0100

> Olivier having laid the groundwork this patch transmits the
> multicast flag to the device to save some bus traffic.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

Applied to net-next, thanks.
