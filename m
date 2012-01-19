From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/9][pull request] Intel Wired LAN Driver Updates
Date: Thu, 19 Jan 2012 12:51:29 -0500 (EST)
Message-ID: <20120119.125129.900596326702615796.davem@davemloft.net>
References: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932129Ab2ASRve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 12:51:34 -0500
In-Reply-To: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Jan 2012 00:13:25 -0800

> The following series contains updates to igb, igbvf, ixgbe and ixgbevf.
> These fixes do the following:
>  - update copyright
>  - fix sparse and/or namespace warnings
>  - make ops tables and strings const
>  - fix defines to handle complex expressions
>  - remove unnecessary irq enable/disable
> 
> The following are changes since commit 17f1bbca1baf2f652fa9c102ec239d6abded94c1:
>   net: ftgmac100/ftmac100: add missing interrupt.h include
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Pulled, thanks Jeff.
