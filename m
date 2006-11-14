From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] WAN: DSCC4 driver requires generic HDLC
Date: Tue, 14 Nov 2006 10:41:14 -0500
Message-ID: <4559E39A.1040009@garzik.org>
References: <m37ixz89nt.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Francois Romieu <romieu@cogenit.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43968 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S966018AbWKNPlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 10:41:18 -0500
To: Krzysztof Halasa <khc@pm.waw.pl>
In-Reply-To: <m37ixz89nt.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Halasa wrote:
> Another thing, reported recently to me by several people - DSCC4 WAN
> driver now (and perhaps for the last couple of years+) requires the
> generic HDLC. I've fixed the Kconfig and moved the DSCC4 option
> under CONFIG_HDLC so it's consistent visually.
> 
> Jeff, Francois, I think it's safe to apply. Thanks.
> 
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

applied


