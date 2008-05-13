From: Jeff Garzik <jeff@garzik.org>
Subject: Re: DM9000: Add __devinit and __devexit attributes to probe and remove
Date: Tue, 13 May 2008 01:18:17 -0400
Message-ID: <48292499.1070805@garzik.org>
References: <20080428151309.GA30439@fluff.org.uk> <4820865F.70703@garzik.org> <20080508103303.GC30439@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Networking <netdev@vger.kernel.org>,
	akpm@linux-foundation.org
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49382 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753487AbYEMFST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 01:18:19 -0400
In-Reply-To: <20080508103303.GC30439@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Dooks wrote:
> From: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
> 
> There were missing __dev* annotations for the dm9000_probe() 
> and dm9000_drv_remove() functions.
> 
> Signed-off-by: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>

applied three dm9000 patches

please number your patches, when submitting multiple ones


