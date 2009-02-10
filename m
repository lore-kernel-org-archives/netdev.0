From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [gkernel-commit] [PATCH 1/3] [ethtool] Add support for RX packet
 classification in a network device
Date: Mon, 09 Feb 2009 19:09:39 -0500
Message-ID: <4990C5C3.7080800@garzik.org>
References: <4990B855.30905@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gkernel-commit@lists.sourceforge.net,
	davem@davemloft.net, Matheos Worku <Matheos.Worku@Sun.COM>,
	Mehdi Bonyadi <Mehdi.Bonyadi@Sun.COM>
To: Santwona.Behera@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50627 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752301AbZBJAJn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2009 19:09:43 -0500
In-Reply-To: <4990B855.30905@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once the ethtool interface change is accepted in the upstream kernel, I 
will be happy to add ethtool(8) support.

I would say, though, adding 1000 lines of code, you might as well put 
that into a new file rxclass.c, to keep all that together in a nice tidy 
unit.

	Jeff




