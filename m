From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 13/14] e1000e: fix incorrect link status when
 switch module pulled
Date: Fri, 21 Nov 2008 17:01:51 -0800 (PST)
Message-ID: <20081121.170151.235363986.davem@davemloft.net>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
	<20081121190239.32313.89514.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44116
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752453AbYKVBBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 20:01:52 -0500
In-Reply-To: <20081121190239.32313.89514.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2008 11:02:39 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> On 82571 with SerDes, the true link state is not always correct when read
> from the STATUS register; use existing e1000_has_link() function instead.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
