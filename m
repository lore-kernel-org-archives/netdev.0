From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Do not register ne2k-pci device until initialized
Date: Sun, 03 May 2009 18:34:47 +0200
Message-ID: <m3ab5uno0o.fsf@intrepid.localdomain>
References: <20090502175811.GA26635@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Lubomir Rintel <lkundrak@v3.sk>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	stable@kernel.org
To: Andreas Mohr <andi@lisas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:59795 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751313AbZECQev (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 May 2009 12:34:51 -0400
In-Reply-To: <20090502175811.GA26635@rhlx01.hs-esslingen.de> (Andreas Mohr's message of "Sat\, 2 May 2009 19\:58\:11 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Mohr <andi@lisas.de> writes:

> Dito arm/ixp4xx_eth.c

Right, will have a patch soon (mainline only, IMHO it's not worth it
to bother "stable" people because of no practical impact of this bug,
especially on this ARM IXP4xx arch).

Thanks.
-- 
Krzysztof Halasa
