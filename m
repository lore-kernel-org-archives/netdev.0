From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/8] Mellanox 100G mlx5 update 2016-11-15
Date: Fri, 18 Nov 2016 12:09:35 -0500 (EST)
Message-ID: <20161118.120935.1004604645720046708.davem@davemloft.net>
References: <1479383162-3432-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33122 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752891AbcKRRJg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 12:09:36 -0500
In-Reply-To: <1479383162-3432-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Thu, 17 Nov 2016 13:45:54 +0200

> This series contains four humble mlx5 features.
> 
> From Gal, 
>  - Add the support for PCIe statistics and expose them in ethtool
> 
> From Huy,
>  - Add the support for port module events reporting and statistics
>  - Add the support for driver version setting into FW (for display purposes only)
> 
> From Mohamad,
>  - Extended the command interface cache flexibility
> 
> This series was generated against commit
> 6a02f5eb6a8a ("Merge branch 'mlxsw-i2c")
> 
> V2:
>  - Changed plain "unsigned" to "unsigned int"

Series applied, thanks.
