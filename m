From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [RFC] [IPv6] spelling fix in /proc:
 /proc/sys/net/ipv6/conf/default/temp_prefered_lft
Date: Wed, 19 Mar 2008 18:56:49 -0700 (PDT)
Message-ID: <20080319.185649.235399151.davem@davemloft.net>
References: <20080319204227.GF6935@ens-lyon.fr>
	<20080319.135205.125229102.davem@davemloft.net>
	<1205976319.26345.20.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benoit.boissinot@ens-lyon.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54315
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752578AbYCTB4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 21:56:34 -0400
In-Reply-To: <1205976319.26345.20.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 19 Mar 2008 18:25:19 -0700

> On Wed, 2008-03-19 at 13:52 -0700, David Miller wrote:
> > From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
> > Date: Wed, 19 Mar 2008 21:42:27 +0100
> > > Here is a patch to fix all the spelling error (prefered -> preferred)
> > I think this doesn't add any value.
> > If the procfs file name has to remain the same, which it does,
> > changing variable and macro names to be different will only
> > cause merge conflicts and pain yet have no redeeming value.
> 
> I disagree.  Proper spelling has value.

Only if it matches the spelling of thing it is implementing!

Making the object being implemented and the variables used to do so
disagree in name will only create other kinds of confusion.
