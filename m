From: David Miller <davem@davemloft.net>
Subject: Re: [patch 8/8] irda: follow lspci device/vendor style
Date: Mon, 22 Sep 2008 19:20:16 -0700 (PDT)
Message-ID: <20080922.192016.97325327.davem@davemloft.net>
References: <200809222150.m8MLohVg031878@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bjorn.helgaas@hp.com, samuel@sortiz.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60622
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754183AbYIWCU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:20:28 -0400
In-Reply-To: <200809222150.m8MLohVg031878@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 22 Sep 2008 14:50:43 -0700

> From: Bjorn Helgaas <bjorn.helgaas@hp.com>
> 
> Use "[%04x:%04x]" for PCI vendor/device IDs to follow the format used by
> lspci(8).
> 
> Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-next-2.6, thanks.
