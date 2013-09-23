From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: sfc-next 2013-09-23
Date: Mon, 23 Sep 2013 16:10:19 -0400 (EDT)
Message-ID: <20130923.161019.1531015327774214021.davem@davemloft.net>
References: <1379962741.2485.58.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753364Ab3IWUKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 16:10:25 -0400
In-Reply-To: <1379962741.2485.58.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 23 Sep 2013 19:59:01 +0100

> The following changes since commit dcb30e659287a6b40dafed1362532da42ec27229:
> 
>   Merge tag 'arm64-stable' of git://git.kernel.org/pub/scm/linux/kernel/git/cmarinas/linux-aarch64 (2013-09-20 08:18:51 -0500)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem
> 
> for you to fetch changes up to c47b2d9d56832e7ff1a20bd598623de42701a3a3:
> 
>   sfc: Support ARFS for IPv6 flows (2013-09-20 19:32:00 +0100)
> 
> 1. Some cleanup from Fengguang Wu and his kbuild robot.
> 2. Support for ethtool register dump on EF10.
> 3. Change soft-TSO to take advantage of firmware assistance on EF10.
> 4. Support for PIO TX buffers and descriptors on EF10, enabled on
> architectures that support write-combining mappings.
> 5. Accelerated RFS support for TCP/IPv6 and UDP/IPv6 on EF10.
> 
> The same changes as in the last request, minus the tracepoints which
> I'll submit separately in a generic form.  This branch has also been
> rebased on a more recent net-next (and re-tested).

Pulled, thanks Ben.
