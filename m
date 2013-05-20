From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] xen-netfront: avoid leaking resources when
 setup_netfront fails
Date: Mon, 20 May 2013 13:43:28 -0700 (PDT)
Message-ID: <20130520.134328.1634344993818261317.davem@davemloft.net>
References: <1369047912-31901-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758203Ab3ETUn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 16:43:29 -0400
In-Reply-To: <1369047912-31901-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 20 May 2013 12:05:12 +0100

> We should correctly free related resources (grant ref, memory page, evtchn)
> when setup_netfront fails.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Applied.
