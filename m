From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/11][pull request] Intel Wired LAN Driver Update
Date: Thu, 23 Jun 2011 23:52:04 -0700 (PDT)
Message-ID: <20110623.235204.552855265637768132.davem@davemloft.net>
References: <1308895397-23133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45205 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497Ab1FXGwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 02:52:18 -0400
In-Reply-To: <1308895397-23133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 23 Jun 2011 23:03:06 -0700

> The following series contains updates to ixgbe.  There are 2 fixes, along
> with several cleanups from Alex and Emil.  In addition, nfc support was added
> as well as bumping the driver version.
> 
> Dropped patch 7 (ixgbe: add support for modifying UDP RSS flow hash options)
> from the previous submission based on comments from Ben H.
> 
> The following are changes since commit 4d054f2f1445aceedab3f9642692d55d2caa7ec6:
>   dcb: use nlmsg_free() instead of kfree()
> and are available in the git repository at:
>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Pulled, thanks Jeff.
