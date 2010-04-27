From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/2] igbvf: double increment nr_frags
Date: Tue, 27 Apr 2010 12:55:49 -0700 (PDT)
Message-ID: <20100427.125549.108791967.davem@davemloft.net>
References: <20100427110107.23872.86247.stgit@localhost.localdomain>
	<20100427110137.23872.8779.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	sanagi.koki@jp.fujitsu.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49587
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756781Ab0D0Tzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 15:55:43 -0400
In-Reply-To: <20100427110137.23872.8779.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Apr 2010 04:01:39 -0700

> From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> 
> There is no need to increment nr_frags because skb_fill_page_desc increments
> it.
> 
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
