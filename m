From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/13] Mellanox ethernet driver update
 Oct-27-2014
Date: Tue, 28 Oct 2014 17:22:12 -0400 (EDT)
Message-ID: <20141028.172212.2293659298646193535.davem@davemloft.net>
References: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbaJ1VWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 17:22:15 -0400
In-Reply-To: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon, 27 Oct 2014 11:37:34 +0200

> This patchset introduces some small bug fixes, support in get/set of
> vlan offload and get/set/capabilities of the link.
> 
> First 7 patches by Saeed, add support in setting/getting link speed and getting
> cable capabilities.
> Next 2 patches also by Saeed, enable the user to turn rx/tx vlan offloading on
> and off.
> Jenni fixed a bug in error flow during device initalization.
> Ido and Jack fixed some code duplication and errors discovered by static checker.
> last patch by me is a fix to make ethtool report the actual rings used by
> indirection QP.
> 
> Patches were applied and tested against commit 61ed53d ("Merge tag 'ntb-3.18'
> of git://github.com/jonmason/ntb")

Series applied to net-next, thanks.
