From: David Miller <davem@davemloft.net>
Subject: Re: [net v2 0/4][pull request] Intel Wired LAN Driver Updates
Date: Fri, 04 May 2012 10:58:15 -0400 (EDT)
Message-ID: <20120504.105815.2251328360345706986.davem@davemloft.net>
References: <1336129504-29919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000Ab2EDO6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 10:58:19 -0400
In-Reply-To: <1336129504-29919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri,  4 May 2012 04:05:00 -0700

> This series of patches contains fixes for ixgbe, igb and e1000.
> 
> v2: Added e1000 patch to fix sparse warnings and igb/ixgbe to
>     correct an issue of calling function to reset Tx queue in
>     init path.
> 
> The following are changes since commit 5a8887d39e1ba5ee2d4ccb94b14d6f2dce5ddfca:
>   sungem: Fix WakeOnLan
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master`

I pulled, but what is that "`" character doing at the end of that GIT url?
I removed it when I pulled as you don't seem to have a "master`" branch in
your tree as far as I can tell.
