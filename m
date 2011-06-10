From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/12][pull request] Intel Wired LAN Driver Update
Date: Fri, 10 Jun 2011 01:20:16 -0700 (PDT)
Message-ID: <20110610.012016.941952296323309008.davem@davemloft.net>
References: <1307677676-26690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754526Ab1FJIUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 04:20:23 -0400
In-Reply-To: <1307677676-26690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  9 Jun 2011 20:47:44 -0700

> The following series is a (smaller) subset of the previous 40 patch
> submission.  This subset only contains updates to e1000e, igb, igbvf
> and rtnetlink.
> 
> e1000e: several cleanups and fixes, as well as bump the version
> igb/igbvf/ixgbevf: bump driver version
> rtnetlink: Compute and store minimum ifinfo dump size
> 
> -v2: fixed infiniband compile issue with the rtnetlink patch
>   
> The following are changes since commit e357964ee66723d0ced63ac1dbd1db4a6a1d417e:
>   bonding: delete unused arp_mon_pt
> and are available in the git repository at:
>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Pulled, thanks Jeff.
