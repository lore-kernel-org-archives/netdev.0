From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cipso: don't follow a NULL pointer when setsockopt()
 is called
Date: Tue, 17 Jul 2012 14:31:37 -0700 (PDT)
Message-ID: <20120717.143137.1363542154253711667.davem@davemloft.net>
References: <20120717210738.22790.23522.stgit@sifl>
	<16005876.GSA3ToWriD@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55068 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756799Ab2GQVbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 17:31:38 -0400
In-Reply-To: <16005876.GSA3ToWriD@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Tue, 17 Jul 2012 17:24:50 -0400

> David, if you don't queue this up for them, let me know and I'll resend it to 
> stable once it hits Linus' tree.

I will be sure to queue it up to -stable when I apply it, as I always
do for appropriate patches.
