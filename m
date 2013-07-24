From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] drivers/net: enic: Move ethtool code to a
 separate file
Date: Wed, 24 Jul 2013 16:06:38 -0700 (PDT)
Message-ID: <20130724.160638.2285834385861935079.davem@davemloft.net>
References: <20130722165918.29393.85753.stgit@savbu-picasso-lnx1.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: neepatel@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518Ab3GXXGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 19:06:39 -0400
In-Reply-To: <20130722165918.29393.85753.stgit@savbu-picasso-lnx1.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neel Patel <neepatel@cisco.com>
Date: Mon, 22 Jul 2013 09:59:18 -0700

> From: Neel Patel <neepatel@cisco.com>
> 
> This patch moves all enic ethtool hooks from enic_main.c to a new file
> enic_ethtool.c
> 
> Signed-off-by: Neel Patel <neepatel@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>
> Signed-off-by: Nishank Trivedi <nistrive@cisco.com>

Applied, thanks.
