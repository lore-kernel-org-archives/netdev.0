From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Subject: Re: [git patches] net driver fixes
Date: Mon, 15 Sep 2008 23:53:08 +0200
Message-ID: <20080915215307.GA10340@alpha.franken.de>
References: <20080915201749.GB3994@havoc.gtf.org> <20080915.132716.267218808.davem@davemloft.net> <20080915204543.GD3994@havoc.gtf.org> <20080915.141442.139271313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:50061 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752855AbYIOVxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2008 17:53:18 -0400
Content-Disposition: inline
In-Reply-To: <20080915.141442.139271313.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2008 at 02:14:42PM -0700, David Miller wrote:
> Most of those changes were complete and utter CRAP.

thank you, but the fix I've sent (de2104x) isn't crap. The bug breaks the 
current debian-installer for Cobalt Qube1, when it tries to get an
IP address via dhcp. 

In my eyes it's a clean and good fix, but I don't care whether it appears
in 2.6.27 or 2.6.28, because debian needs to backport it to 2.6.26
anyway. But declaring bugfixes, which just fixes an very old bug, as
utter crap isn't really nice.

Thomas.

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]
