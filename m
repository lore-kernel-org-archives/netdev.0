From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 14/20] ixgbe: move all Rx DMA control
 register writes to one central location
Date: Thu, 19 Aug 2010 16:47:01 -0700 (PDT)
Message-ID: <20100819.164701.245419617.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819233831.10335.23092.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60443
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754016Ab0HSXqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:46:44 -0400
In-Reply-To: <20100819233831.10335.23092.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:38:34 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change moves all of the Rx DMA control register writes to one central
> location.  This should help to avoid accidentally overwriting existing
> settings.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
