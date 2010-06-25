From: David Miller <davem@davemloft.net>
Subject: Re: tcp: sending reset to the already closed socket
Date: Thu, 24 Jun 2010 21:56:33 -0700 (PDT)
Message-ID: <20100624.215633.233693894.davem@davemloft.net>
References: <4C1A2502.1030502@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: khorenko@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43291
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750877Ab0FYE4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 00:56:23 -0400
In-Reply-To: <4C1A2502.1030502@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Your email was a better commit message (lots of useful traces and
information and analysis, that will be useful to someone in the future
looking at this commit) than your patch's actual commit message which
was terse and non-descriptive.  :-)

So I combined the two :-)

I've applied this to net-next-2.6, if this problem causes serious
documentable grief for a significant number of real users we can
toss it into net-2.6 or -stable later.

Thanks!
