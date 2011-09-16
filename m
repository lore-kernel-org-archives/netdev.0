From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/11][pull request] Intel Wired LAN Driver Updates
Date: Fri, 16 Sep 2011 15:20:35 -0400 (EDT)
Message-ID: <20110916.152035.734918963189057900.davem@davemloft.net>
References: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755207Ab1IPTUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 15:20:39 -0400
In-Reply-To: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 15 Sep 2011 21:42:42 -0700

> The following series contains updates to ixgbe only.  These are primarily
> cleanups of the ixgbe driver.  The first two patches of the series:
> 
>   ixgbe: Change default Tx work limit size to 256 buffers
>   ixgbe: consolidate all MSI-X ring interrupts and poll routines into one
> 
> are re-worked based on previous community feedback (Dave and Ben).
> 
> The following are changes since commit 4bc71cb983fd2844e603bf633df2bb53385182d2:
>   net: consolidate and fix ethtool_ops->get_settings calling
> and are available in the git repository at:
>   git://github.com/Jkirsher/net-next.git

Pulled, thanks Jeff.
