From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [2.6 patch] net/ipv4/ipvs/: remove unused exports
Date: Mon, 12 Nov 2007 08:58:36 +0100
Message-ID: <20071112075836.GE9771@stusta.de>
References: <20071111064840.GJ21669@stusta.de> <20071111070939.GA25304@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Rumen G. Bogdanovski" <rumen@voicecho.com>, wensong@linux-vs.org,
	ja@ssi.bg, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	LVS Development mailing list
	<lvs-devel@linuxvirtualserver.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:33149 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751277AbXKLH7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 02:59:00 -0500
Content-Disposition: inline
In-Reply-To: <20071111070939.GA25304@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 11, 2007 at 04:09:40PM +0900, Simon Horman wrote:
> On Sun, Nov 11, 2007 at 07:48:40AM +0100, Adrian Bunk wrote:
> > This patch removes the following unused EXPORT_SYMBOL's:
> > - ip_vs_try_bind_dest
> > - ip_vs_find_dest
> > 
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> Looks fine to me.
> 
> Should Dave Miller put this in his tree,
> or do you want to handle it a different way?
>...

If Dave applies it that would be perfect.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

