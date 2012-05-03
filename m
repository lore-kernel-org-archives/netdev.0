From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ucc_geth, increase no. of HW RX descriptors
Date: Wed, 02 May 2012 20:10:10 -0400 (EDT)
Message-ID: <20120502.201010.149609774304936802.davem@davemloft.net>
References: <1335775015-14718-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim.Tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893Ab2ECALe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 20:11:34 -0400
In-Reply-To: <1335775015-14718-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Mon, 30 Apr 2012 10:36:54 +0200

> In a busy network we see ucc_geth is dropping RX pkgs every now
> and then. Increase the RX queues HW descriptors from
> 16 to 32 to deal with this.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

Applied.
