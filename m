From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] Mellanox drivers updates Feb-03-2015
Date: Wed, 04 Feb 2015 16:18:09 -0800 (PST)
Message-ID: <20150204.161809.1955935953080569817.davem@davemloft.net>
References: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755666AbbBEASK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 19:18:10 -0500
In-Reply-To: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue,  3 Feb 2015 17:57:14 +0200

> This patchset introduces some small bug fixes and code cleanups in mlx4_core,
> mlx4_en and mlx5_core.
> I am sending it in parallel to the patchset sent by Or Gerlitz today [1] because
> this is the end of the time frame for 3.20. I also checked that there are no
> conflicts between those two patchsets (Or's patchset is focused on the bonding
> area while this on Mellanox drivers).
> 
> The patchset was applied on top of commit 7d37d0c ('net: sctp: Deletion of an
> unnecessary check before the function call "kfree"')
> 
> [1] - [PATCH 00/10] Add HA and LAG support to mlx4 RoCE and SRIOV services
>       http://marc.info/?l=linux-netdev&m=142297582610254&w=2

Series applied, thanks.
