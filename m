From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/2][pull request] Intel Wired LAN Driver Update
Date: Sat, 02 Jun 2012 17:08:15 -0400 (EDT)
Message-ID: <20120602.170815.2112883345165687929.davem@davemloft.net>
References: <1338621416-22425-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965256Ab2FBVIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 17:08:19 -0400
In-Reply-To: <1338621416-22425-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat,  2 Jun 2012 00:16:54 -0700

> This series contains fixes for e1000 and e1000e.
> 
> The following are changes since commit ad1be8d345416a794dea39761a374032aa471a76:
>   r8169: call netif_napi_del at errpaths and at driver unload
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master
> 
> Bruce Allan (1):
>   e1000e: fix Rapid Start Technology support for i217
> 
> Sebastian Andrzej Siewior (1):
>   e1000: look into the page instead of skb->data for
>     e1000_tbi_adjust_stats()

Pulled, thanks Jeff.
