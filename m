From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [IrDA] Initial support for MCS7780 based dongles
Date: Thu, 25 May 2006 16:19:36 -0700 (PDT)
Message-ID: <20060525.161936.28396410.davem@davemloft.net>
References: <20060525061926.GB24611@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	bpugh@cs.pdx.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17580
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S965132AbWEYXTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 19:19:31 -0400
To: samuel@sortiz.org
In-Reply-To: <20060525061926.GB24611@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Thu, 25 May 2006 06:19:27 +0000

> The MosChip MCS7780 chipset is an IrDA USB bridge that
> doesn't conform with the IrDA-USB standard and thus needs
> its separate driver.
> Tested on an actual MCS7780 based dongle.
> 
> Original implementation by Brian Pugh <bpugh@cs.pdx.edu>
> 
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

New feature, so applied to net-2.6.18, thanks.
