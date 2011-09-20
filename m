From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/9][pull request] Intel Wired LAN Driver Update
Date: Tue, 20 Sep 2011 14:38:11 -0400 (EDT)
Message-ID: <20110920.143811.1935829567594845372.davem@davemloft.net>
References: <1316502690-25488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560Ab1ITSia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 14:38:30 -0400
In-Reply-To: <1316502690-25488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 20 Sep 2011 00:11:21 -0700

> The following series contains updates to igb only.  This is a smaller
> subset of an earlier push request I sent, minus the problem/dependent
> patches.  The missing patches are:
>   ixgb: eliminate checkstack warnings (Jesse has a v2 in test now)
>   igb: Make Tx budget for NAPI user adjustable (I am reworking)
> these patches were not included as well since they were somewhat dependent
> on the patch I am currently re-working.
>   igb: split buffer_info into tx_buffer_info and rx_buffer_info
>   igb: Consolidate creation of Tx context descriptors into a single
> 
> The following are changes since commit 765cf9976e937f1cfe9159bf4534967c8bf8eb6d:
>   tcp: md5: remove one indirection level in tcp_md5sig_pool
> and are available in the git repository at:
>   git://github.com/Jkirsher/net-next.git

Pulled, thanks Jeff.
