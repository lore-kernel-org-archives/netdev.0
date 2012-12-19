From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] solos-pci: add GPIO support for newer versions on
 Geos board
Date: Wed, 19 Dec 2012 14:54:02 -0800 (PST)
Message-ID: <20121219.145402.549071758733855665.davem@davemloft.net>
References: <1355950881-31550-1-git-send-email-dwmw2@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nathan@traverse.com.au
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168Ab2LSWyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 17:54:03 -0500
In-Reply-To: <1355950881-31550-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 19 Dec 2012 21:01:18 +0000

> From: Nathan Williams <nathan@traverse.com.au>
> 
> dwmw2: Tidy up a little, simpler matching on which GPIO is being accessed,
>        only register on newer boards, register under PCI device instead of
>        duplicating them under each ATM device.
> 
> Signed-off-by: Nathan Williams <nathan@traverse.com.au>
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Applied.
