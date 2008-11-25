From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 1/2] igb: remove unneeded bit refrence when
 enabling jumbo frames
Date: Tue, 25 Nov 2008 01:03:35 -0800 (PST)
Message-ID: <20081125.010335.130059998.davem@davemloft.net>
References: <20081124234845.24515.6891.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34618
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751928AbYKYJDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 04:03:35 -0500
In-Reply-To: <20081124234845.24515.6891.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 24 Nov 2008 15:48:45 -0800

> There is a reference to a Buffer Size extention bit that is unneded by
> 82575/82576 hardware.  Since it is not needed it should be removed from the
> code.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
