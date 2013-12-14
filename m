From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: sfc-next 2013-12-12
Date: Sat, 14 Dec 2013 01:11:40 -0500 (EST)
Message-ID: <20131214.011140.1782125225508708522.davem@davemloft.net>
References: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796Ab3LNGLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 01:11:42 -0500
In-Reply-To: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 12 Dec 2013 22:56:17 +0000

> An assortment of changes for Linux 3.14:
> 
> 1. Merge the sfc fixes that you have already merged into net.git.
>    (The branch point for those was such that this does not bring in any
>    other changes.)
> 2. Reduce log level for a generally useless warning message, from
>    Robert Stonehouse.
> 3. Include BISTs in ethtool offline self-test for EF10 and recover from
>    BISTs initiated through other functions, from Jon Cooper.
> 4. Improve a sanity check on RX completions.
> 5. Avoid incrementing RX dropped count while the interface is down, from
>    Jon Cooper.
> 6. Improve hardware sensor naming and log messages, from Edward Cree.
> 7. Log all unexpected errors returned by firmware, from Edward Cree.
> 8. Expose another NVRAM partition to userland.
> 9. Some refactoring of the PTP code in preparation for EF10 support.
> 10. Various minor cleanups.

Pulled, thanks Ben.
