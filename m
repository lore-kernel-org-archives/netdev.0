From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: disallow enslaving a bond to itself
Date: Wed, 26 Feb 2014 22:37:48 -0500 (EST)
Message-ID: <20140226.223748.40193665509267854.davem@davemloft.net>
References: <20140226172013.GA18145@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbaB0Dhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 22:37:51 -0500
In-Reply-To: <20140226172013.GA18145@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Wed, 26 Feb 2014 18:20:13 +0100

> Enslaving a bond to itself leads to an endless loop and hangs the kernel.
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Applied, thank you.
