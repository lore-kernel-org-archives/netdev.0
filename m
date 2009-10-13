From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix IXP 2000 network driver building.
Date: Tue, 13 Oct 2009 00:03:23 -0700 (PDT)
Message-ID: <20091013.000323.180016269.davem@davemloft.net>
References: <1255376775-21390-1-git-send-email-vince@simtec.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vince@simtec.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52396
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751442AbZJMHD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 03:03:28 -0400
In-Reply-To: <1255376775-21390-1-git-send-email-vince@simtec.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Sanders <vince@simtec.co.uk>
Date: Mon, 12 Oct 2009 20:46:15 +0100

> The IXP 2000 network driver was failing to build as it has its own
> statistics gathering which was not compatible with the recent network
> device operations changes. This patch fixes the driver in the obvious
> way and has been compile tested. I have been unable to get the ixp2000
> maintainer to comment or test this fix.
> 
> Signed-off-by: Vincent Sanders <vince@simtec.co.uk>

Looks good enough for me, applied, thanks!
