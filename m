From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Update
Date: Thu, 09 Jun 2011 00:05:05 -0700 (PDT)
Message-ID: <20110609.000505.2259375858864240000.davem@davemloft.net>
References: <1307573800-24868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38570 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753619Ab1FIHFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 03:05:09 -0400
In-Reply-To: <1307573800-24868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  8 Jun 2011 15:56:28 -0700

> The following series is a (smaller) subset of the previous 40 patch
> submission.  This subset only contains updates to e1000e, igb, igbvf
> and rtnetlink.
> 
> e1000e: several cleanups and fixes, as well as bump the version
> igb/igbvf/ixgbevf: bump driver version
> rtnetlink: Compute and store minimum ifinfo dump size
> 
> The following are changes since commit ffbc03bc75b39c7bd412e7cc6d2185c11b0ffedd:
>   net: add needed interrupt.h
> and are available in the git repository at:
>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Pulled, thanks Jeff.
