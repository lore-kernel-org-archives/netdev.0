From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Convert to net_device_ops
Date: Wed, 25 Mar 2009 00:35:16 +0100
Message-ID: <OF3500930F.BEAC23ED-ONC1257583.008165CC-C1257583.0081924C@transmode.se>
References: <OF603BDF0B.B740DD77-ONC1257583.007CAD9B-C1257583.007CFD35@transmode.se>	<20090324.154902.206324978.davem@davemloft.net>
	<OF4B79F4DE.4DC6DEA7-ONC1257583.007ECBEA-C1257583.007F2805@transmode.se> <20090324.162913.226453070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: avorontsov@ru.mvista.com, leoli@freescale.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:49430 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753967AbZCXXfT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 19:35:19 -0400
In-Reply-To: <20090324.162913.226453070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 25/03/2009 00:29:13:
> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Date: Wed, 25 Mar 2009 00:08:53 +0100
> 
> > David Miller <davem@davemloft.net> wrote on 24/03/2009 23:49:02:
> > > 
> > > From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > > Date: Tue, 24 Mar 2009 23:45:13 +0100
> > > 
> > > > I don't follow. Are these mandatory now? They were not in the old
> > > > impl. either.
> > > 
> > > See ether_setup() which is called indirectly via alloc_etherdev().
> > > 
> > > Yawn...
> > 
> > Same here, getting tiered. Should have seen that. Here goes,
> > attatched as well as explained earlier.
> 
> I'll apply this, thanks.

Thanks.
> 
> Please provide a proper "Signed-off-by:" line with future
> patch submissions, thanks.

Yep, getting tiered ...
Hopefully I will have something more coming your way the next few days.


