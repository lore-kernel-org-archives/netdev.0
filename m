From: David Miller <davem@davemloft.net>
Subject: Re: csum offload and af_packet
Date: Sun, 17 Aug 2008 16:08:25 -0700 (PDT)
Message-ID: <20080817.160825.22400712.davem@davemloft.net>
References: <20080812.175532.137434164.davem@davemloft.net>
	<20080813010935.GA29815@gondor.apana.org.au>
	<48A2C4DE.20005@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@axxeo.de,
	rusty@rustcorp.com.au, anthony@codemonkey.ws,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54317
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751493AbYHQXIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 19:08:25 -0400
In-Reply-To: <48A2C4DE.20005@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 13 Aug 2008 13:26:22 +0200

> Actually the current CVS version understands auxdata and uses it to
> reconstruct VLAN headers. CVS seems to be broken though, I can send
> you a tarball with the current version if you want.

At first I thought you were saying that the code in their current
CVS is broken, but now I understand that CVS itself is broken for
this project.

That's rediculious.

I'll see if I can put some time together to try and put some trees
together, please send me what you have Patrick, thanks.

If I'm successful I'll put GIT trees up on kernel.org for tcpdump
and libpcap which we can hack on.

Thanks guys.
