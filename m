From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] igb: add support for reporting 5GT/s
 during probe on PCIe Gen2
Date: Tue, 27 Apr 2010 12:55:54 -0700 (PDT)
Message-ID: <20100427.125554.55850374.davem@davemloft.net>
References: <20100427110238.23921.24825.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49591
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756752Ab0D0Tzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 15:55:48 -0400
In-Reply-To: <20100427110238.23921.24825.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Apr 2010 04:02:40 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change corrects the fact that we were not reporting Gen2 link speeds
> when we were in fact connected at Gen2 rates.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
