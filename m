From: David Miller <davem@davemloft.net>
Subject: Re: can: convert to %pK for kptr_restrict support
Date: Thu, 26 May 2011 14:24:49 -0400 (EDT)
Message-ID: <20110526.142449.1044028921930345889.davem@davemloft.net>
References: <4DDE6A71.3080406@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, drosenberg@vsecurity.com
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51071 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757897Ab1EZSZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 14:25:23 -0400
In-Reply-To: <4DDE6A71.3080406@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Thu, 26 May 2011 16:57:53 +0200

> As these pointers have been printed without using %p they were missed in the
> big network kptr_restrict conversion patch %p -> %pK from Dan Rosenberg.
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Applied.
