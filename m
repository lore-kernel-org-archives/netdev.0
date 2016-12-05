From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/6] net/mlx5: Verify module parameters
Date: Mon, 05 Dec 2016 15:05:39 -0500 (EST)
Message-ID: <20161205.150539.1019585301109119643.davem@davemloft.net>
References: <1480848976-6797-1-git-send-email-saeedm@mellanox.com>
        <1480848976-6797-2-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kamalh@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49822 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752185AbcLEUFl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 15:05:41 -0500
In-Reply-To: <1480848976-6797-2-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Sun,  4 Dec 2016 12:56:11 +0200

> +static uint prof_sel = MLX5_DEFAULT_PROF;

Please do not use type shorthands such as "uint", always expand
fully "unsigned int".

Thanks.
