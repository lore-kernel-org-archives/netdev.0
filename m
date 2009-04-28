From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/3] ixgbe: Interrupt management update for
 82599
Date: Tue, 28 Apr 2009 01:55:45 -0700 (PDT)
Message-ID: <20090428.015545.101796120.davem@davemloft.net>
References: <20090428084236.32710.14750.stgit@localhost.localdomain>
	<20090428084254.32710.36207.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, shannon.nelson@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37633
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756156AbZD1Izw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:55:52 -0400
In-Reply-To: <20090428084254.32710.36207.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 28 Apr 2009 01:42:54 -0700

> Update the interrupt management to correctly handle greater
> than 16 queue vectors.
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
