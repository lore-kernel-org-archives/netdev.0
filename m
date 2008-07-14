From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: bnx2_poll panicking kernel
Date: Mon, 14 Jul 2008 23:48:51 +0200
Message-ID: <20080714214851.GB4849@ami.dom.local>
References: <20080710.162007.04790623.davem@davemloft.net> <20080711092416.GA26515@orion.carnet.hr> <20080711.025656.261409874.davem@davemloft.net> <48787E1A.3030804@gmail.com> <4878AFD8.1000307@gmail.com> <487B7061.5040306@trash.net> <20080714172055.GA2638@ami.dom.local> <20080714202151.GA28622@orion.carnet.hr> <20080714212223.GA4849@ami.dom.local> <20080714212620.GA8503@orion.carnet.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, mchan@broadcom.com,
	billfink@mindspring.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, mirrors@debian.org, devik@cdi.cz
To: Josip Rodin <joy@entuzijast.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:6613 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756631AbYGNVrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 17:47:19 -0400
Received: by fk-out-0910.google.com with SMTP id 18so3010314fkq.5
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 14:47:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080714212620.GA8503@orion.carnet.hr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2008 at 11:26:20PM +0200, Josip Rodin wrote:
...
> No (sorry :) but he did call his patch an "idiotic attempt", and asked you
> guys for input, so I held back :)

And, IMHO, you were right. With more complex config (filters with
actions) there could be some difference, but you didn't mention such.

...
> OK, I'll give it a whirl.
> 
> (Should I update to .26 at the same time, now that it went live in the
> meantime?)

My proposal is to try .25 first.

Jarek P.
