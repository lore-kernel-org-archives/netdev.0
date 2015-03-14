From: David Miller <davem@davemloft.net>
Subject: Re: [next-queue 0/7][pull request] Intel Wired LAN Driver Updates
 2015-03-13
Date: Sat, 14 Mar 2015 15:08:15 -0400 (EDT)
Message-ID: <20150314.150815.937408473066008614.davem@davemloft.net>
References: <1426291248-14739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbbCNTIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 15:08:18 -0400
In-Reply-To: <1426291248-14739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 13 Mar 2015 17:00:41 -0700

> This series contains updates to ixgbe and ixgbevf.
> 
> Don adds additional support for X550 MAC types, which require additional
> steps around enabling and disabling Rx.  Also cleans up variable type
> inconsistency.
> 
> I provide a patch to allow relaxed ordering to be enabled on SPARC
> architectures.  Also cleans up ixgbevf whitespace and code comments to
> align the driver with networking coding standard.  Lastly cleaned up
> uses of memcpy() where ether_addr_copy() could have been used.
> 
> Alex removes some dead code in the ixgbe cleanup patch.

Pulled, thanks Jeff.
