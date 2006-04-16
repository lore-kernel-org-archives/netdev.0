From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC: 2.6 patch] net/irda/irias_object.c: remove unused exports
Date: Sun, 16 Apr 2006 19:37:19 +0100
Message-ID: <1145212639.5656.3.camel@localhost.localdomain>
References: <20060414114446.GL4162@stusta.de>
	 <20060414164203.GA24146@bougret.hpl.hp.com>
	 <1145209616.3809.14.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, Adrian Bunk <bunk@stusta.de>,
	Samuel.Ortiz@nokia.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:8370 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1750785AbWDPSeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 14:34:21 -0400
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1145209616.3809.14.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sul, 2006-04-16 at 19:46 +0200, Arjan van de Ven wrote:
> > 	Personally, I don't see what this patch buy us...
> 
> all the unused exports in the kernel together make a binary kernel 100Kb
> bigger. It's a case of a lot of little steps I suppose (each export
> taking like 100 to 150 bytes depending on the size of the function name)


So why are exports taking us 100-150 bytes, not say 20 which is what I'd
expect ?

