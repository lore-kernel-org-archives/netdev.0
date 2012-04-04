From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/8][pull request] Intel Wired LAN Driver Update
Date: Wed, 04 Apr 2012 04:26:31 -0400 (EDT)
Message-ID: <20120404.042631.2130868853739722658.davem@davemloft.net>
References: <1333526160-24937-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511Ab2DDI0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 04:26:40 -0400
In-Reply-To: <1333526160-24937-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  4 Apr 2012 00:55:52 -0700

> This series of patches contains updates for e1000, e1000e, igb and
> ixgbe.  The e1000 patch finishes up the addition of RXALL support
> flag from Ben Greear.  The 2 igb patches adds the PTP support
> from Richard Cochran.  The remaining patches for e1000e and ixgbe
> are cleanup patches (and rev the e1000e driver).
> 
> The following are changes since commit 68df25d6c556c4df4dad32a0585317eab356e325:
>   bnx2x: Change to driver version 1.72.10-0
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks Jeff.
