From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Fix unable to get UP event from the LLD
Date: Fri, 02 Nov 2012 21:42:02 -0400 (EDT)
Message-ID: <20121102.214202.155876506809130895.davem@davemloft.net>
References: <1351512156-11636-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, dm@chelsio.com,
	jay@chelsio.com
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49385 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab2KCBmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 21:42:04 -0400
In-Reply-To: <1351512156-11636-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul@chelsio.com>
Date: Mon, 29 Oct 2012 17:32:36 +0530

> If T4 configuration file gets loaded from the /lib/firmware/cxgb4/ directory
> then offload capabilities of the cards were getting disabled during
> initialization. Hence ULDs do not get an UP event from the LLD.
> 
> Signed-off-by: Jay Hernandez <jay@chelsio.com>
> Signed-off-by: Vipul Pandya <vipul@chelsio.com>

Applied, thanks.
