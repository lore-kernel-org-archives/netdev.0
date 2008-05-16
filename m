From: David Miller <davem@davemloft.net>
Subject: Re: [NET] [BUG-FIX] [Patch 1/1]: Revert use of skb_padto
Date: Fri, 16 May 2008 13:09:52 -0700 (PDT)
Message-ID: <20080516.130952.05903749.davem@davemloft.net>
References: <20080502202940.GA5116@gerrit.erg.abdn.ac.uk>
	<20080502144503.4ef2a430@extreme>
	<20080516171702.GA1615@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40894
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754115AbYEPUJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:09:57 -0400
In-Reply-To: <20080516171702.GA1615@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 16 May 2008 18:17:02 +0100

> [SC92031]: Using padto turned driver into an IPv6-only interface

Gerrit, as per the "NETWORK DEVICE DRIVERS" entry in MAINTAINERS, Jeff
Garzik handles network driver patches, who them passes them on to me
after he reviews and integrates them.

So please always CC: him for such things.

Thanks.
