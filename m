From: David Miller <davem@davemloft.net>
Subject: Re: csum offload and af_packet
Date: Sun, 17 Aug 2008 18:12:11 -0700 (PDT)
Message-ID: <20080817.181211.141651078.davem@davemloft.net>
References: <48A2C4DE.20005@trash.net>
	<20080817.160825.22400712.davem@davemloft.net>
	<20080818011018.GA31337@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@axxeo.de, rusty@rustcorp.com.au,
	anthony@codemonkey.ws, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54043
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751002AbYHRBMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 21:12:12 -0400
In-Reply-To: <20080818011018.GA31337@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 18 Aug 2008 11:10:18 +1000

> On Sun, Aug 17, 2008 at 04:08:25PM -0700, David Miller wrote:
> >
> > I'll see if I can put some time together to try and put some trees
> > together, please send me what you have Patrick, thanks.
> > 
> > If I'm successful I'll put GIT trees up on kernel.org for tcpdump
> > and libpcap which we can hack on.
> 
> That's awesome! Thanks Dave!

There is a libpcap.git up in my dir on kernel.org:

	master.kernel.org:/pub/scm/linux/kernel/git/davem/libpcap.git

It's just a bare 0.9.8 import plus a commit to get rid of all of the
rcsid strings.
