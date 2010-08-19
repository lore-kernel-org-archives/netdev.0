From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 05/20] ixgbe: move configuration of the
 MTQC register into it's own function
Date: Thu, 19 Aug 2010 16:46:13 -0700 (PDT)
Message-ID: <20100819.164613.39161804.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819233447.10335.56588.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60424
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753962Ab0HSXp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:45:56 -0400
In-Reply-To: <20100819233447.10335.56588.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:34:50 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch moves the configuration of the MTQC register into it's own
> function call similar to ixgbe_setup_mrqc.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
