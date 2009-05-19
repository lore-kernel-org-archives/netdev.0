From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] ixgbe: Cleanup feature setup code to
 make the code more readable
Date: Tue, 19 May 2009 14:41:12 -0700 (PDT)
Message-ID: <20090519.144112.229814966.davem@davemloft.net>
References: <20090519191819.5063.28388.stgit@localhost.localdomain>
	<20090519191911.5063.75627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37761
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753013AbZESVlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 17:41:14 -0400
In-Reply-To: <20090519191911.5063.75627.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 19 May 2009 12:19:11 -0700

> This is purely a cleanup patch.  This collapses some of the code required
> when we configure our Tx and Rx feature sets, and makes the code more
> readable and maintainable.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
