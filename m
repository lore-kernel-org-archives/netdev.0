From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2][XFRM]: Sub-policies beautification
Date: Fri, 17 Nov 2006 17:52:42 +0100
Message-ID: <20061117165242.GF8693@postel.suug.ch>
References: <1163772616.5107.40.camel@jzny2> <20061117164253.GE8693@postel.suug.ch> <1163782194.5219.3.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Masahide NAKAMURA <nakam@linux-ipv6.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:19596 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1755736AbWKQQwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 11:52:21 -0500
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1163782194.5219.3.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-11-17 11:49
> Good catch. I think i know how i missed that one - TheLinuxWay;->
> theres a few __u8s in there unrelated. So i will send an additional
> patch that fixes that and the rest of em. Sounds good?

Sure
