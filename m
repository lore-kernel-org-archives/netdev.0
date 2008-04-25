From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Fri, 25 Apr 2008 13:10:11 +0200
Message-ID: <m3prse2nsc.fsf@maximus.localdomain>
References: <m3r6cv75xq.fsf@maximus.localdomain>
	<20080424.063006.153647297.davem@davemloft.net>
	<m3mynj74nw.fsf@maximus.localdomain>
	<20080424.065555.30390704.davem@davemloft.net>
	<m3ve27nfpx.fsf@maximus.localdomain>
	<20080424214457.1d5a1655@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	paulkf@microgate.com, jchapman@katalix.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:33508 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751454AbYDYLKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 07:10:14 -0400
In-Reply-To: <20080424214457.1d5a1655@the-village.bc.nu> (Alan Cox's message of "Thu\, 24 Apr 2008 21\:44\:57 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

> I would agree with this. There isn't a sane way to sort out the old
> kernel side syncppp (which is useless for todays networks as it doesn't
> do compression, IPv6 or auth protocols) except by going to user space.

Well, I never used compression or auth on fixed line, and that would
require generic PPP. Perhaps we should use it, I don't know.
-- 
Krzysztof Halasa
