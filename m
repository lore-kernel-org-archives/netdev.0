From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] atlx: Use ETH_ALEN
Date: Mon, 19 Mar 2012 16:58:20 -0400 (EDT)
Message-ID: <20120319.165820.1896441211313260247.davem@davemloft.net>
References: <cover.1332128181.git.joe@perches.com>
	<1670f6450b7624f8aa92ef2c08c6aa0d0e5d5ef9.1332128181.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jcliburn@gmail.com,
	chris.snook@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478Ab2CSU60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 16:58:26 -0400
In-Reply-To: <1670f6450b7624f8aa92ef2c08c6aa0d0e5d5ef9.1332128181.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 18 Mar 2012 20:37:57 -0700

> No need for yet another #define for this.
> 
> Convert NODE_ADDRESS_SIZE use to ETH_ALEN and remove #define.
> Use memcpy instead of a loop to copy an address.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
