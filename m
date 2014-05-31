From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] be2net: patch set
Date: Fri, 30 May 2014 17:28:35 -0700 (PDT)
Message-ID: <20140530.172835.203975562412535198.davem@davemloft.net>
References: <1401258665-6238-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932699AbaEaA2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 20:28:36 -0400
In-Reply-To: <1401258665-6238-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 28 May 2014 12:00:59 +0530

> Patch 1 is a minor optimization for issuing multicast promisc FW cmd
> only when the interface is not already in that mode.
> 
> Patch 2 provides support for VF TX-rate setting on Skyhawk-R.
> 
> Patch 3 provides support for flashing new FW flash regions.
> 
> Patches 4, 5, 6 cleanup the MCC processing (for FW cmds) code in be_cmds.c.
> The MCC error reporting and event handling code are areas that needed
> cleanup.
> 
> Pls consider applying to the net-next tree. Thanks.

Applied, although you should give a response to Sergei's feedback.

Thank you.
