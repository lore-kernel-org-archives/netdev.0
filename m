From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] e1000e: Fix for offline diag test failure
 at first call
Date: Mon, 18 Oct 2010 08:12:31 -0700 (PDT)
Message-ID: <20101018.081231.39167647.davem@davemloft.net>
References: <20101016033452.2174.51928.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	carolyn.wyborny@intel.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40967
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756632Ab0JRPMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 11:12:09 -0400
In-Reply-To: <20101016033452.2174.51928.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 15 Oct 2010 20:35:31 -0700

> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> Move link test call to later in the offline sequence, move the
> restore settings block to afterwards and add another reset to ensure
> the hardware is in a known state afterwards.
> 
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Acked-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
