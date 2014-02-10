From: Steffen Klassert <steffen@klassert.de>
Subject: Re: [PATCH/RESEND] 3c59x: Remove unused pointer in
 vortex_eisa_cleanup()
Date: Mon, 10 Feb 2014 13:50:53 +0100
Message-ID: <20140210125053.GC14187@slnx.de>
References: <20140208181117.6776b154@spike>
 <20140208201023.731538cf@spike>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Christian Engelmayer <cengelma@gmx.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from master.slnx.de ([144.76.43.239]:46530 "EHLO master.slnx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752660AbaBJM6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Feb 2014 07:58:31 -0500
Content-Disposition: inline
In-Reply-To: <20140208201023.731538cf@spike>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 08, 2014 at 08:10:23PM +0100, Christian Engelmayer wrote:
> Remove unused network device private data pointer 'vp' in function
> vortex_eisa_cleanup(). Detected by Coverity: CID 139826.
> 
> Signed-off-by: Christian Engelmayer <cengelma@gmx.at>
> ---
> Resend using address steffen@klassert.de as retrieved from the mail delivery
> fail notification by tu-chemnitz.de. Information in MAINTAINERS seems to be
> outdated on that point.

Oh yes, it expired at the beginning of the year. I'll do a
patch to update the maintainers entry. Thanks for the info!
