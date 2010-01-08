From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] igb: add support for device reset
 interrupt
Date: Fri, 08 Jan 2010 01:02:56 -0800 (PST)
Message-ID: <20100108.010256.254849765.davem@davemloft.net>
References: <20100108034058.31805.96712.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54459
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752204Ab0AHJCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 04:02:48 -0500
In-Reply-To: <20100108034058.31805.96712.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 07 Jan 2010 19:41:00 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch adds support for the global device reset interrupt.  Without
> this change the drivers will report tx hangs on all ports when a global
> device reset occurs.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
