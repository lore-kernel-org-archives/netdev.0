From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Thu, 09 Aug 2012 03:42:42 -0700 (PDT)
Message-ID: <20120809.034242.1518689666898097694.davem@davemloft.net>
References: <1344505152-28167-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755837Ab2HIKmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 06:42:43 -0400
In-Reply-To: <1344505152-28167-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Date: Thu,  9 Aug 2012 02:39:09 -0700

> This series contains bugfixes to the igb and e1000e drivers.
> 
> The following are changes since commit 36471012e2ae28ca3178f84d4687a2d88a36593e:
>   
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/ppwaskie/net master
> 
> Alexander Duyck (1):
>   igb: Fix register defines for all non-82575 hardware
> 
> Emil Tantilov (2):
>   igb: fix panic while dumping packets on Tx hang with IOMMU
>   e1000e: fix panic while dumping packets on Tx hang with IOMMU

Pulled, thanks PJ.
