From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: remove redundant replay_esn check
Date: Fri, 9 Nov 2012 08:59:22 +0100
Message-ID: <20121109075921.GE22290@secunet.com>
References: <20121108101544.GA30309@uweber-WS>
 <20121108.220020.884271049343560692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ulrich.weber@sophos.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57750 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751073Ab2KIH7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2012 02:59:31 -0500
Content-Disposition: inline
In-Reply-To: <20121108.220020.884271049343560692.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 08, 2012 at 10:00:20PM -0500, David Miller wrote:
> From: Ulrich Weber <ulrich.weber@sophos.com>
> Date: Thu, 8 Nov 2012 11:15:44 +0100
> 
> > x->replay_esn is already checked in if clause,
> > so remove check and ident properly
> > 
> > Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
> 
> Steffen, I assume you'll pick this one up.

Yes, it was already in my queue. Now applied to ipsec-next.

Thanks!
