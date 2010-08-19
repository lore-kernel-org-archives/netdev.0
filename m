From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 08/20] ixgbe: pull ring configuration into
 it's own function
Date: Thu, 19 Aug 2010 16:46:31 -0700 (PDT)
Message-ID: <20100819.164631.48527022.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819233602.10335.80879.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60441
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753962Ab0HSXqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:46:15 -0400
In-Reply-To: <20100819233602.10335.80879.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:36:05 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> These changes add ixgbe_configure_rx_ring which is used to setup the base
> function pointers for the ring.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
