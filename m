From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c509: Add missing EISA IDs
Date: Sat, 30 May 2009 22:58:47 -0700 (PDT)
Message-ID: <20090530.225847.209029911.davem@davemloft.net>
References: <alpine.LFD.1.10.0905310021070.15490@ftp.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58016
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751761AbZEaF6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2009 01:58:47 -0400
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

Please send networking driver patches to me, not Jeff Garzik,
as per current linux/MAINTAINERS

Thanks.
