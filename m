From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] pasemi_mac: Fix building as module
Date: Tue, 06 Dec 2011 00:49:40 -0500 (EST)
Message-ID: <20111206.004940.937781986961368502.davem@davemloft.net>
References: <1323150262.7454.247.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, olof@lixom.net, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744Ab1LFFtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 00:49:49 -0500
In-Reply-To: <1323150262.7454.247.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 06 Dec 2011 05:44:22 +0000

> Commit ded19addf9c937d83b9bfb4d73a836732569041b ('pasemic_mac*: Move
> the PA Semi driver') inadvertently split pasemi_mac into two separate
> modules with unresolved symbols.  Change it back into a single module.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> The build failure can currently be seen at
> <https://buildd.debian.org/status/package.php?p=linux-2.6&suite=experimental>.

Applied, thanks Ben.
