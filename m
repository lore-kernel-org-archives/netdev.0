From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/12] drivers/net organize Ethernet drivers (7th
 series)
Date: Sat, 13 Aug 2011 01:05:44 -0700 (PDT)
Message-ID: <20110813.010544.734245982051486279.davem@davemloft.net>
References: <1313222196-10074-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907Ab1HMIFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2011 04:05:48 -0400
In-Reply-To: <1313222196-10074-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 13 Aug 2011 00:56:24 -0700

> This is the seventh of seven 10 patch series (although this series is 12
> patches) to move the Ethernet drivers into drivers/net/ethernet/.
> 
> There is still a bit of cleanup left (FDDI, PPP, SLIP, etc), which will
> be coming shortly and small in comparison to the Ethernet driver move.
>   
> The following are changes since commit 9bba23b0ae933a143f8ea89e59c6becf0c1c1d1e:
>   starfire: Move the Adaptec driver
> and are available in the git repository at:
>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize master

Pulled, thanks a lot Jeff.
