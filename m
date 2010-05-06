From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/2] e1000e: Reset 82577/82578 PHY before
 first PHY register read
Date: Thu, 06 May 2010 01:23:01 -0700 (PDT)
Message-ID: <20100506.012301.55861124.davem@davemloft.net>
References: <20100506075959.8910.13493.stgit@localhost.localdomain>
	<20100506080025.8910.45557.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34246
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754768Ab0EFIWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 04:22:54 -0400
In-Reply-To: <20100506080025.8910.45557.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 06 May 2010 01:00:27 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Reset the PHY before first accessing it.  Doing so, ensure that the PHY is
> in a known good state before we read/write PHY registers. This fixes a
> driver probe failure.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
