From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/2][pull request] Intel Wired LAN Driver Updates
Date: Thu, 26 Apr 2012 05:11:12 -0400 (EDT)
Message-ID: <20120426.051112.593865044382599274.davem@davemloft.net>
References: <1335333314-6814-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216Ab2DZJLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 05:11:17 -0400
In-Reply-To: <1335333314-6814-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 24 Apr 2012 22:55:12 -0700

> This series of patches contains fixes for e1000e only.
> 
> The following are changes since commit 2a5809499e35b53a6044fd34e72b242688b7a862:
>   asix: Fix tx transfer padding for full-speed USB
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master
> 
> Jeff Kirsher (1):
>   e1000e: Fix default interrupt throttle rate not set in NIC HW
> 
> Prasanna S Panchamukhi (1):
>   e1000e: MSI interrupt test failed, using legacy interrupt

Pulled, but longer term you guys might want to take Ben's suggestion
and just take the interrupt self-test out altogether.

Thanks.
