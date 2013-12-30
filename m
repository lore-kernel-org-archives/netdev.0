From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] namespace collision fix and update FW version
 check on cxgb4
Date: Sun, 29 Dec 2013 22:30:21 -0500 (EST)
Message-ID: <20131229.223021.1188738781129653670.davem@davemloft.net>
References: <1387798320-29255-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183Ab3L3DaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 22:30:23 -0500
In-Reply-To: <1387798320-29255-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Mon, 23 Dec 2013 17:01:57 +0530

> Patch 1/3 (cxgb4: make functions static and remove dead code) was provided by
> Stephen Hemminger on netdev mailing list.
> http://www.spinics.net/lists/linux-rdma/msg18148.html

Such cleanups really are not appropriate for 'net'.
