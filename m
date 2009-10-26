From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/5] e1000e: 82577/82578 requires a different
 method to configure LPLU
Date: Mon, 26 Oct 2009 16:17:16 -0700 (PDT)
Message-ID: <20091026.161716.77489022.davem@davemloft.net>
References: <20091026212242.9682.25442.stgit@localhost.localdomain>
	<20091026212325.9682.22270.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49855
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754626AbZJZXQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 19:16:53 -0400
In-Reply-To: <20091026212325.9682.22270.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 26 Oct 2009 14:23:25 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Unlike previous ICHx-based parts, the PCH-based parts (82577/82578) require
> LPLU (Low Power Link Up, or "reverse auto-negotiation") to be configured in
> the PHY rather than the MAC.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
