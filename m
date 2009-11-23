From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] ixgbe: Modify 82599 HWRSC statistics
 counters
Date: Mon, 23 Nov 2009 10:46:18 -0800 (PST)
Message-ID: <20091123.104618.112039312.davem@davemloft.net>
References: <20091123163145.19706.37720.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38700
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754495AbZKWSqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 13:46:00 -0500
In-Reply-To: <20091123163145.19706.37720.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 23 Nov 2009 08:32:06 -0800

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> Divide 82599 HWRSC counters into aggregated and flushed to count number of
> packets getting coalesced per TCP connection.
> 
> Signed-off-by:  Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
