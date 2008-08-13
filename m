From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dccp: change L/R must have at least one byte in the
 dccpsf_val field
Date: Wed, 13 Aug 2008 13:49:04 -0700 (PDT)
Message-ID: <20080813.134904.123902363.davem@davemloft.net>
References: <20080813125532.GD12888@ghostprotocols.net>
	<44269.148.187.160.35.1218639843.squirrel@148.187.160.35>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org, dccp@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35917
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752242AbYHMUtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 16:49:03 -0400
In-Reply-To: <44269.148.187.160.35.1218639843.squirrel@148.187.160.35>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gerrit@erg.abdn.ac.uk
Date: Wed, 13 Aug 2008 16:04:03 +0100 (BST)

> > dccp: change L/R must have at least one byte in the dccpsf_val field
> >
> > Thanks to Eugene Teo for reporting this problem.
> >
> > Signed-off-by: Eugene Teo <eugenete@kernel.sg>
> > Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> 
> Dave, can you please apply -- this patch is for mainline only.

Applied and I'll queue this up for -stable too, thanks everyone.
