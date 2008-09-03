From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [2.6 patch] wan/hdlc_x25.c: fix a NULL dereference
Date: Wed, 03 Sep 2008 18:14:40 +0200
Message-ID: <m3bpz5kxzj.fsf@maximus.localdomain>
References: <20080827220549.GS11734@cs181140183.pp.htv.fi>
	<m3bpz9glik.fsf@maximus.localdomain> <48BE9B52.8050003@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@kernel.org>, Jeff Garzik <jgarzik@redhat.com>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:47179 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752000AbYICQOm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 12:14:42 -0400
In-Reply-To: <48BE9B52.8050003@garzik.org> (Jeff Garzik's message of "Wed\, 03 Sep 2008 10\:12\:34 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jeff@garzik.org> writes:

> In terms of patches... what does this mean?  Does this mean you are
> taking Adrian's patch, and updating it?  Sending a follow-up patch?
> Ack'ing Adrian's patch?
>
> I don't want to hold this back due to lack of stat update...

Right... The attached patch should do it. Sorry for the delay.
-- 
Krzysztof Halasa
