From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Convert to net_device_ops
Date: Tue, 24 Mar 2009 16:29:13 -0700 (PDT)
Message-ID: <20090324.162913.226453070.davem@davemloft.net>
References: <OF603BDF0B.B740DD77-ONC1257583.007CAD9B-C1257583.007CFD35@transmode.se>
	<20090324.154902.206324978.davem@davemloft.net>
	<OF4B79F4DE.4DC6DEA7-ONC1257583.007ECBEA-C1257583.007F2805@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, leoli@freescale.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Joakim.Tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35143
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753837AbZCXX30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 19:29:26 -0400
In-Reply-To: <OF4B79F4DE.4DC6DEA7-ONC1257583.007ECBEA-C1257583.007F2805@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Wed, 25 Mar 2009 00:08:53 +0100

> David Miller <davem@davemloft.net> wrote on 24/03/2009 23:49:02:
> > 
> > From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > Date: Tue, 24 Mar 2009 23:45:13 +0100
> > 
> > > I don't follow. Are these mandatory now? They were not in the old
> > > impl. either.
> > 
> > See ether_setup() which is called indirectly via alloc_etherdev().
> > 
> > Yawn...
> 
> Same here, getting tiered. Should have seen that. Here goes,
> attatched as well as explained earlier.

I'll apply this, thanks.

Please provide a proper "Signed-off-by:" line with future
patch submissions, thanks.
