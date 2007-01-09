From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] INET: fix incorrect "inet_sock->is_icsk" assignment
Date: Tue, 9 Jan 2007 09:43:22 +0100
Message-ID: <20070109084322.GB1703@ff.dom.local>
References: <20070108132548.GA2324@ff.dom.local> <200701080947.29270.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:52421 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751146AbXAIIlb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 03:41:31 -0500
To: Paul Moore <paul.moore@hp.com>
Content-Disposition: inline
In-Reply-To: <200701080947.29270.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 08, 2007 at 09:47:29AM -0500, Paul Moore wrote:
...
> I guess it all depends on who is reading it ;)

Sure! I only had a feeling your way is maybe slightly
less often used so I wanted some opinion.

> Personally, I don't care too 
> much either way as long as it is fixed.

Yes, you've done great work, no doubt. But if you
consider this code will probably become classical
and will be read, quoted and teached next 1000
years, then the style could matter...

Cheers,
Jarek P. 
