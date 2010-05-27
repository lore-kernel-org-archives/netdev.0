From: Ajit Khaparde <ajitk@serverengines.com>
Subject: Re: [net-next PATCH] be2net: Adding PCI SRIOV support
Date: Thu, 27 May 2010 19:29:47 +0530
Message-ID: <20100527135945.GA15134@serverengines.com>
References: <6f264a7a-e5da-494a-a24d-1578ca422807@VA3EHSMHS016.ehs.local>
 <5AC56E9F58E6EE4681447596FAECEC6DAA6506@ad-1.austin.nextio>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Venugopal Busireddy <venu@nextio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:42218 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754954Ab0E0OJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 10:09:24 -0400
Content-Disposition: inline
In-Reply-To: <5AC56E9F58E6EE4681447596FAECEC6DAA6506@ad-1.austin.nextio>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/05/10 12:55 -0500, Venugopal Busireddy wrote:
> 
> David,
> >> From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
> >> Date: Wed, 31 Mar 2010 18:26:12 +0530
> >> - Patch adds support to enable PCI SRIOV in the driver and changes to
> handle \
> >>                initialization of PCI virtual functions.
> >> - Function handler to change mac addresses for VF from its
> corresponding PF.
> >> 
> >> Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
> >Applied, thanks.
>  I checked the 2.6.34 kernel, and could not see this patch applied in
> it. In which kernel would this patch be available? Also, if I were to
> apply this patch, which kernel version would this patch require?
You wouldn't see these changes in 2.6.34
They were pushed to Linus tree post 2.6.34 release.
You can take the latest driver from Linus git repository.

-Ajit
