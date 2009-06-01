From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c509: Add missing EISA IDs
Date: Mon, 01 Jun 2009 03:12:15 -0700 (PDT)
Message-ID: <20090601.031215.109417436.davem@davemloft.net>
References: <alpine.LFD.1.10.0905310021070.15490@ftp.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49667
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756217AbZFAKMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 06:12:14 -0400
In-Reply-To: <alpine.LFD.1.10.0905310021070.15490@ftp.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Sun, 31 May 2009 00:40:31 +0100 (BST)

>  Several EISA device IDs for 3c509 family network cards are missing from 
> the driver, making the cards unusable in their EISA mode.  Here's a fix to 
> add them based on the EISA configuration files distributed by 3Com and our 
> eisa.ids database.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

Applied, thanks.
