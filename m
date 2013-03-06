From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: sfc 2013-03-06
Date: Wed, 06 Mar 2013 14:51:52 -0500 (EST)
Message-ID: <20130306.145152.1643159075664695517.davem@davemloft.net>
References: <1362597261.3126.11.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, scrum-linux@solarflare.com,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716Ab3CFTvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 14:51:54 -0500
In-Reply-To: <1362597261.3126.11.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 6 Mar 2013 19:14:21 +0000

> The following changes since commit aab2b4bf224ef8358d262f95b568b8ad0cecf0a0:
> 
>   tcp: fix double-counted receiver RTT when leaving receiver fast path (2013-03-04 14:12:07 -0500)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.9
> 
> Fix regressions introduced by the last set of fixes (sorry):
> 
> 1. Potential deadlock when disabling TX queues.
> 2. RX was broken on architectures other than x86 and powerpc.
> 
> I still expect to send one more bug fix for 3.9, but as it sometimes
> takes days to reproduce the bug it's going to take a couple of weeks of
> testing to be confident that it's really fixed.

Pulled, thanks Ben.
