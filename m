From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next 1/2] netem: rate-latency extension
Date: Fri, 25 Nov 2011 02:23:50 +0100
Message-ID: <20111125012349.GI2673@hell>
References: <1322156378-23257-1-git-send-email-hagen@jauu.net>
 <1322172898.2872.7.camel@edumazet-laptop>
 <20111124223118.GH2673@hell>
 <20111124200650.c1f609ef.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:39778 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753244Ab1KYBXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 20:23:52 -0500
Content-Disposition: inline
In-Reply-To: <20111124200650.c1f609ef.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Bill Fink | 2011-11-24 20:06:50 [-0500]:

>From the user perspective, I also find rate much more natural.
>No need to add further to tc obscurity.

ok, then I will respin the patch.

>I would ask for an update to the netem man page, but I guess
>there isn't a netem man page.  :-(

Someone wrote a man page, but it was never commited to iproute2. I will have a
look.

Hagen
