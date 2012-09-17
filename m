From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Mon, 17 Sep 2012 12:44:37 -0400 (EDT)
Message-ID: <20120917.124437.2293118473934200209.davem@davemloft.net>
References: <1347873709-2190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matthew.vick@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59040 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970Ab2IQQoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 12:44:39 -0400
In-Reply-To: <1347873709-2190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 17 Sep 2012 02:21:43 -0700

> The following are changes since commit ba01dfe18241bf89b058fd8a60218b218ad2bb30:
>   Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
> 
> Matthew Vick (6):
>   igb: Tidy up wrapping for CONFIG_IGB_PTP.
>   igb: Update PTP function names/variables and locations.
>   igb: Correct PTP support query from ethtool.
>   igb: Store the MAC address in the name in the PTP struct.
>   igb: Prevent dropped Tx timestamps via work items and interrupts.
>   igb: Add 1588 support to I210/I211.

Pulled, thanks for fixing this up.
