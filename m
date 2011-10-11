From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/11 v2][pull request] Intel Wired LAN Driver
 Updates
Date: Tue, 11 Oct 2011 15:25:39 -0400 (EDT)
Message-ID: <20111011.152539.381627107095548221.davem@davemloft.net>
References: <1318347952-25068-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754933Ab1JKTZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 15:25:47 -0400
In-Reply-To: <1318347952-25068-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 11 Oct 2011 08:45:41 -0700

> The following series contains updates to e1000e and igb.  This
> version of the series contains the following changes:
> 
> - Added the e1000e bug fix patch
> - Dropped the igb patch "igb: Use node specific allocations for
>   the q_vectors and rings" based on feedback
> 
> Based on the feedback, I am working on re-working the igb patch that
> was dropped in this series and will re-submit it later on.
> 
> The remain 10 igb patches are unchanged from the previous pull request
> and are the continuation of the cleanups and refactoring that Alex has done.
> After this series there are 4-5 more patches to complete the work
> that Alex has done on igb.
> 
> The following are changes since commit 3ed6f6958c0ac21958285d8648f14d34da4bbcb3:
>   ll_temac: convert to SKB paged frag API.
> and are available in the git repository at
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git

Pulled, thanks Jeff.
