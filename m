From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] be2net: add descriptions for stat counters
 reported via ethtool
Date: Wed, 01 Feb 2012 14:25:22 -0500 (EST)
Message-ID: <20120201.142522.908710587550609261.davem@davemloft.net>
References: <1327904259-14583-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420Ab2BATZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 14:25:27 -0500
In-Reply-To: <1327904259-14583-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Mon, 30 Jan 2012 11:47:39 +0530

> Also rename a few counters appropritely and delete 2 counters that are not
> implemented in HW.
> 
> vlan_mismatch_drops does not exist in BE3 and is accounted for in
> address_mismatch_drops. Do the same thing for BE2 and Lancer.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied, thanks.
