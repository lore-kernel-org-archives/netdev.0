From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Please pull for-2.6.26 branch of linux-2.6-mv643xx_eth.git
Date: Sat, 12 Apr 2008 05:10:10 -0400
Message-ID: <48007C72.5000906@pobox.com>
References: <20080401190314.GA13017@farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lennert Buytenhek <buytenh@marvell.com>
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41647 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753389AbYDLJKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:10:14 -0400
In-Reply-To: <20080401190314.GA13017@farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dale Farnsworth wrote:
> Hi Jeff,
> 
> Please pull from the following git repository:
>   git://git.farnsworth.org/dale/linux-2.6-mv643xx_eth.git for-2.6.26
> 
> It contains the commits below, which were previously posted on netdev.
> 
> Thanks,
> -Dale
> 
> 
> Lennert Buytenhek (7):
>       mv643xx_eth: mp->tx_desc_count needs spinlock protection
>       mv643xx_eth: various cleanups
>       mv643xx_eth: identify ports by struct mv643xx_private *
>       mv643xx_eth: report netdev name in all printks
>       mv643xx_eth: pass port identifier to register accessors
>       mv643xx_eth: only print banner once
>       mv643xx_eth: update copyright

pulled


