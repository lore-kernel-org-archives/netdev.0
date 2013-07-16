From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] drivers/net: enic: Move ethtool code to a
 separate file
Date: Tue, 16 Jul 2013 16:50:19 -0700 (PDT)
Message-ID: <20130716.165019.1396321151263713703.davem@davemloft.net>
References: <20130716233936.29788.10598.stgit@savbu-picasso-lnx1.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: neepatel@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41888 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933898Ab3GPXuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 19:50:22 -0400
In-Reply-To: <20130716233936.29788.10598.stgit@savbu-picasso-lnx1.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neel Patel <neepatel@cisco.com>
Date: Tue, 16 Jul 2013 16:39:36 -0700

> From: Neel Patel <neepatel@cisco.com>
> 
> This patch moves all enic ethtool hooks from enic_main.c to a new file
> enic_ethtool.c
> 
> Signed-off-by: Neel Patel <neepatel@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>
> Signed-off-by: Nishank Trivedi <nistrive@cisco.com>

As I have announced repeatedly on this list, net-next is not open
at this time and changes such as this should only be submitted when
I announce here that the net-next tree is open again.

Thanks.
