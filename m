From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 03/14] e1000e: 82571 check for link fix on
 82571 serdes
Date: Fri, 21 Nov 2008 16:50:45 -0800 (PST)
Message-ID: <20081121.165045.216757089.davem@davemloft.net>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
	<20081121185939.32313.20366.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42254
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754949AbYKVAuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:50:46 -0500
In-Reply-To: <20081121185939.32313.20366.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2008 10:59:39 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Check for link test does not work properly for 82571 parts in a blade
> environment with an unterminated serdes link partner.  Make the test more
> robust by checking the invalid bit.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
