From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] e1000e: disable ASPM L1 on 82573
Date: Thu, 19 Aug 2010 15:48:58 -0700 (PDT)
Message-ID: <20100819.154858.226796327.davem@davemloft.net>
References: <20100819224307.10079.89643.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com, stable@kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42336
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752982Ab0HSWsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 18:48:41 -0400
In-Reply-To: <20100819224307.10079.89643.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 15:43:46 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> On the e1000-devel mailing list, Nils Faerber reported latency issues with
> the 82573 LOM on a ThinkPad X60.  It was found to be caused by ASPM L1;
> disabling it resolves the latency.  The issue is present in kernels back
> to 2.6.34 and possibly 2.6.33.
> 
> 
> Reported-by: Nils Faerber <nils.faerber@kernelconcepts.de>
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Cc: stable@kernel.org
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
