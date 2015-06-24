From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 00/11] Mellanox NIC drivers update, June 23
 2015
Date: Wed, 24 Jun 2015 00:47:40 -0700 (PDT)
Message-ID: <20150624.004740.2140216964529747690.davem@davemloft.net>
References: <1435068862-26488-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, talal@mellanox.com,
	achiad@mellanox.com, saeedm@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648AbbFXHfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 03:35:54 -0400
In-Reply-To: <1435068862-26488-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 23 Jun 2015 17:14:11 +0300

> This series has two fixes from Eran to his recent SRIOV counters work in 
> mlx4 and few more updates from Saeed and Achiad to the mlx5 Ethernet
> code. All fixes here relate to net-next code, so no need for -stable.
 ...
>  - dropped the patch that move us to poll RX completions 1st, based
>    on feedback from Dave.

Series applied, thanks.
