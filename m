From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: fscked clock sources revisited
Date: Mon, 30 Jul 2007 18:10:18 -0700
Message-ID: <1185844218.2683.0.camel@laptopd505.fenrus.org>
References: <1185844239.5162.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Robert.Olsson@data.slu.se,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:50193 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932345AbXGaBNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 21:13:07 -0400
In-Reply-To: <1185844239.5162.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-07-30 at 21:10 -0400, jamal wrote:
> Folks,
> 
> I have posted this before but got no good response and i havent had time
> to chase it. 
> While doing some batching tests with pktgen and then with a simple
> client server app with udp, it does appear that the clock source used
> matters. Here are some basic runs with plain vanilla 2.6.22-rc4 runs
> with udp. There are five runs per clock source and each result is in
> Mbps.

can you make sure hpet is enabled as well?


