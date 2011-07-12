From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/4][pull request] Intel Wired LAN Driver Update
Date: Mon, 11 Jul 2011 20:07:49 -0700 (PDT)
Message-ID: <20110711.200749.1031001326186588317.davem@davemloft.net>
References: <1310436914-4017-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092Ab1GLDHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 23:07:54 -0400
In-Reply-To: <1310436914-4017-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 11 Jul 2011 19:15:10 -0700

> The following series contains updates to igb and ixgbe.
> 
> igb- a fix of adding a flush after a register write, the addition
>     of SerDes forced mode support and a trivial update of copyright
>     header.
> 
> ixgbe- fix to initialize fdir_perfect_lock in all cases
> 
> Dropped the conversion to ndo_fix_features patch from Don Skidmore so that
> Don can fix up the patch based on the suggestions from Michal Miroslaw
>   
> The following are changes since commit d84e0bd7971eb8357c700151ee4e8e4101ee65fa:
>   skbuff: update struct sk_buff members comments
> and are available in the git repository at:
>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Pulled, thanks!
