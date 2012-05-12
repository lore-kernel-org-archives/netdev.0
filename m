From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v3 0/2][pull request] Intel Wired LAN Driver Updates
Date: Sat, 12 May 2012 17:56:19 -0400 (EDT)
Message-ID: <20120512.175619.544127478795872151.davem@davemloft.net>
References: <1336854637-6708-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab2ELV4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 17:56:23 -0400
In-Reply-To: <1336854637-6708-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 12 May 2012 13:30:35 -0700

> This series of patches contains updates for igb.  Most notably,
> the addition of i210 & i211 support.
> 
> v2: fix up patch 2 based on feedback from David Miller
> v3: fix compiler warning
> 
> The following are changes since commit 4b549a2ef4bef9965d97cbd992ba67930cd3e0fe:
>   fq_codel: Fair Queue Codel AQM
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Ok, this works, pulled (for real) :-)
