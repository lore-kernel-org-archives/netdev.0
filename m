From: David Miller <davem@davemloft.net>
Subject: Re: pull request: sfc 2012-02-25
Date: Fri, 24 Feb 2012 22:13:44 -0500 (EST)
Message-ID: <20120224.221344.239668103276907715.davem@davemloft.net>
References: <1330132277.2397.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769Ab2BYDNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 22:13:49 -0500
In-Reply-To: <1330132277.2397.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 25 Feb 2012 01:11:17 +0000

> The following changes since commit 8a49ad6e89feb5015e77ce6efeb2678947117e20:
> 
>   ppp: fix 'ppp_mp_reconstruct bad seq' errors (2012-02-24 17:53:21 -0500)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.3
> 
> (commit ff3bc1e7527504a93710535611b2f812f3bb89bf)
> 
> Fixes incorrect marking of skbs as checksummed.  Please send this on to
> stable as well; the bug was introduced in 2.6.37.

Pulled and queued up for -stable, thanks.
