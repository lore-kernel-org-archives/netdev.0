From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/10] MLSXFRM-v02: Auto-labeling of child sockets
Date: Thu, 27 Jul 2006 21:59:54 -0700 (PDT)
Message-ID: <20060727.215954.74747479.davem@davemloft.net>
References: <44BD196C.6000307@trustedcs.com>
	<44C8EF98.3020507@trustedcs.com>
	<Pine.LNX.4.64.0607280050590.13981@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyekkirala@trustedcs.com, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, sds@tycho.nsa.gov, tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63895
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932576AbWG1E7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 00:59:55 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0607280050590.13981@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Fri, 28 Jul 2006 00:53:30 -0400 (EDT)

> On Thu, 27 Jul 2006, Venkat Yekkirala wrote:
> 
> > Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
> 
> Acked-by: James Morris <jmorris@namei.org>
> 
> > --- NOTE: Not sure what the ideal thing to do is here. The following is 
> > incremental to the original patch. I can send a revision of the entire 
> > patch with these changes if desired.
> 
> Send it to Andrew Morton saying it replaces
> 
>   git-net-selinux_xfrm_decode_session-build-fix.patch
> 
> and with any luck, he'll drop the old fix and add this one.

Don't bother, I'll add it to my net-2.6.19 tree and Andrew will
get it, and purge the old patch, automatically.

Thanks guys. :)
