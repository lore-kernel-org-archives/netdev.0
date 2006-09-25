From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 00/03][RESUBMIT] net: EtherIP tunnel driver
Date: 25 Sep 2006 12:22:41 +0200
Message-ID: <p738xk8kzym.fsf@verdi.suse.de>
References: <20060923120704.GA32284@zlug.org>
	<20060923121327.GH30245@lug-owl.de> <1159015118.5301.19.camel@jzny2>
	<20060923.163535.41636370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbglaw@lug-owl.de, joro-lkml@zlug.org, kaber@trash.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:3226 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1750876AbWIYKWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 06:22:54 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060923.163535.41636370.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> 
> First, the only mentioned real use of EtherIP I've seen anywhere is to
> tunnel old LAN based games that used protocols other than IP :-)

How would you convince those old LAN games to use a MTU < 1500 which
is needed for the tunnel?  I bet they have the size hardcoded.

-Andi
