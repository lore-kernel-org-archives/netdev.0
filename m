From: DiegoB <diego.beltrami@hiit.fi>
Subject: Re: [XFRM]: Optimize MTU calculation
Date: Tue, 03 Apr 2007 23:00:40 +0300
Message-ID: <4612B268.6060204@hiit.fi>
References: <46128290.5060701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Miika Komu <miika@iki.fi>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:60777 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422673AbXDCU3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 16:29:43 -0400
In-Reply-To: <46128290.5060701@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> I've updated my IPsec MTU optimization patch I've posted a couple
> of month ago to net-2.6.22 and added the further optimization
> suggested by Herbert to account for the space lost due to alignment
> in the room reserved for IP options in transport mode.
> 
> Tested with IPv4 and IPv6 in tunnel and transport mode. Beet mode
> is untested since no keying daemon seems to support it.

Actually for BEET mode you can check the following:

http://hipl.hiit.fi/
http://www.openhip.org/
http://www.hip4inter.net/

Cheers,

Diego


