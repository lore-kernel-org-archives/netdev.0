From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 0/7][pull request] Intel Wired LAN Driver Updates
Date: Wed, 02 May 2012 19:45:35 -0400 (EDT)
Message-ID: <20120502.194535.73059000886850739.davem@davemloft.net>
References: <1335950025-13294-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	bhutchings@solarflare.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985Ab2EBXpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 19:45:42 -0400
In-Reply-To: <1335950025-13294-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  2 May 2012 02:13:38 -0700

> This series of patches contains updates for e1000e and ixgbe.
> Patch 4 & 5 integrate the hwmon interface for ixgbe as Ben Hutchings
> has done for other drivers.
> 
> v2: dropped the ixgbe patch which added the sysfs interface
> 
> The following are changes since commit e4ae004b84b315dd4b762e474f97403eac70f76a:
>   netem: add ECN capability
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks Jeff.
