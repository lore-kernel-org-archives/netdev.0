From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [BUG] 2.6.30-rc broke ixp4xx_eth, firmware breakage?
Date: Sun, 19 Apr 2009 22:03:02 +0200
Message-ID: <m3vdp0pg21.fsf@intrepid.localdomain>
References: <200904182153.n3ILrP6j027453@pilspetsen.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mikael Pettersson <mikpe@it.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:54504 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755688AbZDSUDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Apr 2009 16:03:07 -0400
In-Reply-To: <200904182153.n3ILrP6j027453@pilspetsen.it.uu.se> (Mikael Pettersson's message of "Sat\, 18 Apr 2009 23\:53\:25 +0200 \(MEST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mikael Pettersson <mikpe@it.uu.se> writes:

> The ixp4xx_eth driver for my IXP420 XScale box (Synology DS101)
> worked fine in kernel 2.6.29. Now trying to boot 2.6.30-rc2 I'm
> greeted with the following failure during init:
>
> Bringing up interface eth0:  RTNETLINK answers: No such file or directory
> Failed to bring up eth0.
> [FAILED]

Thanks for the info, will look at it.
-- 
Krzysztof Halasa
