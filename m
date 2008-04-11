From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Fri, 11 Apr 2008 23:35:23 +0200
Message-ID: <m37if4oz1g.fsf@maximus.localdomain>
References: <m3prtzsszg.fsf@maximus.localdomain>
	<m3tzj92xq6.fsf@maximus.localdomain>
	<m33aqedg0a.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ZSM1387.piap.pl ([195.187.100.11]:59890 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754952AbYDKVfZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 17:35:25 -0400
In-Reply-To: <m33aqedg0a.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Tue\, 25 Mar 2008 15\:39\:49 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I wrote:

> So are we leaving the generic-HDLC+PPP in broken state for 2.6.25,
> aren't we?
>
> If we do, perhaps a "|| BROKEN" in drivers/net/wan/Kconfig would make
> sense?

Linus just made 2.6.25-rclast (I hope), I understand 2.6.25 will have
broken drivers/net/wan/hdlc_ppp, any chance to apply the temporary
Kconfig ("depends on BROKEN") patch?

Would you like me to resend it?

TIA.
-- 
Krzysztof Halasa
