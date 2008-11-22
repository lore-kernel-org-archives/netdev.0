From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 05/14] e1000e: check return of pci_save_state
Date: Fri, 21 Nov 2008 16:51:39 -0800 (PST)
Message-ID: <20081121.165139.35223075.davem@davemloft.net>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
	<20081121190015.32313.73483.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42263
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755016AbYKVAvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:51:40 -0500
In-Reply-To: <20081121190015.32313.73483.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2008 11:00:15 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Check return of pci_save_state and error out accordingly.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
