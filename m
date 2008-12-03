From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH net-2.6 1/2] jme: GHC register control fix for new hardware
Date: Wed, 03 Dec 2008 10:00:25 -0500
Message-ID: <49369F09.2010302@pobox.com>
References: <20080915165101.M68109@cooldavid.org> <48D27CDA.50501@pobox.com> <20081008215853.M53590@cooldavid.org> <20081203103825.M4442@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ethan <ethanhsiao@jmicron.com>, akeemting <akeem@jmicron.com>
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38369 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751275AbYLCPAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 10:00:34 -0500
In-Reply-To: <20081203103825.M4442@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guo-Fu Tseng wrote:
> Dear Jeff, David:
> 
> Due to the hardware design, except the first chip on the market,
> other chips needs to setup the clock source for MAC processor
> implicitly through Global Host Control Register(GHC).
> (Strange design huh?)
> 
> 10/100M uses the PCI-E as clock source, and 1G uses GPHY.
> 
> And I reordered the code a little, to make it easier to read.
> 
> Found-by: "Ethan" <ethanhsiao@jmicron.com>
> Fixed-by: "akeemting" <akeem@jmicron.com>
> Signed-off-by: "Guo-Fu Tseng" <cooldavid@cooldavid.org>

patches 1-2 Acked-by: Jeff Garzik <jgarzik@redhat.com>


