From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [ethtool] Add support for RX packet classification
 in a network device
Date: Mon, 09 Feb 2009 19:44:00 -0800 (PST)
Message-ID: <20090209.194400.247227644.davem@davemloft.net>
References: <4990B855.30905@Sun.COM>
	<20090209.180306.156744968.davem@davemloft.net>
	<4990F1B5.2070002@Sun.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gkernel-commit@lists.sourceforge.net,
	jeff@garzik.org, Matheos.Worku@Sun.COM, Mehdi.Bonyadi@Sun.COM
To: Santwona.Behera@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35577
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752417AbZBJDoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 22:44:08 -0500
In-Reply-To: <4990F1B5.2070002@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santwona.Behera@Sun.COM
Date: Mon, 09 Feb 2009 19:17:09 -0800

> The interfaces assumes that they are to be specified in network
> order. I will add a comment to mention that.
> 
> Looking back at my ethtool(8) patch, I have a bug in the code where
> I do not do this translation for the ports and spi (I got it right
> for the IP addresses). I will fix this and repost all the patches.

Thank you.
