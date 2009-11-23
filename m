From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] ixgbe: Use rx buffer length from rx
 ring for configuring rscctl
Date: Mon, 23 Nov 2009 10:46:23 -0800 (PST)
Message-ID: <20091123.104623.218407112.davem@davemloft.net>
References: <20091123163145.19706.37720.stgit@localhost.localdomain>
	<20091123163230.19706.77806.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38704
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754803AbZKWSqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 13:46:06 -0500
In-Reply-To: <20091123163230.19706.77806.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 23 Nov 2009 08:32:31 -0800

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> While configuring rscctl use rx buffer length from rx ring structure
> instead of passing rx_buf_len to ixgbe_configure_rscctl
> 
> Signed-off-by:  Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
