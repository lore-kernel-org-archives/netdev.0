From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 19/20] ixgbe: update all DESC_ADV macros
 to accept a ring pointer
Date: Thu, 19 Aug 2010 16:47:27 -0700 (PDT)
Message-ID: <20100819.164727.15262966.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819234028.10335.95335.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60472
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754061Ab0HSXrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:47:10 -0400
In-Reply-To: <20100819234028.10335.95335.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:40:31 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> All of the DESC_ADV macros are currently needing the pointers to be
> de-referenced before accessing the ring.  Instead of having to add all of
> the asterisks it is easier to just update the macro to expect a pointer to
> the ring.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
