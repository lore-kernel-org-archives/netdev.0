From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: fix sparse warnings
Date: Wed, 10 Sep 2014 14:01:15 -0700 (PDT)
Message-ID: <20140910.140115.2110252161894113517.davem@davemloft.net>
References: <1410350570-6145-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43339 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbaIJVBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 17:01:16 -0400
In-Reply-To: <1410350570-6145-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Wed, 10 Sep 2014 14:02:50 +0200

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> This fixes the following sparse warnings:
> sparse: symbol 'tipc_update_nametbl' was not declared. Should it be static?
> Also, the function is changed to return bool upon success, rather than a
> potentially freed pointer.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
