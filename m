From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] net/mlx4: Performance enhancement and
 cleanups
Date: Tue, 06 Mar 2012 15:20:06 -0500 (EST)
Message-ID: <20120306.152006.1441594424671261261.davem@davemloft.net>
References: <4F561931.1000002@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030950Ab2CFUUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 15:20:14 -0500
In-Reply-To: <4F561931.1000002@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Tue, 6 Mar 2012 16:03:29 +0200

> Hi Dave,
> This patch consists of a patch with datapath pointer optimizations, which was submitted a week ago
> and you agreed to accept it after resubmission.
> In addition, there are 7 cleanup patches that remove sparse warnings for mlx4 drivers.
> 
> Or Gerlitz (2):
>   net/mlx4: fix sparse warnings on TX control flags endianess
>   net/mlx4: fix sparse warnings on TX blue flame buffer
> 
> Yevgeny Petrilin (6):
>   net/mlx4_en: Saving mem access on data path
>   net/mlx4: fix sparse warnings on wrong type for RSS keys
>   net/mlx4: fixing sparse warnings when copying mac address to gid entry
>   net/mlx4: fixing sparse warnings for not declared functions
>   net/mlx4: remove unused functions
>   net/mlx4: defining functions as static

Series applied, thanks.
