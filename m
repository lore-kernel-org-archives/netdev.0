From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool: e1000: fix a typo
Date: Tue, 19 Sep 2006 14:58:35 -0400
Message-ID: <45103DDB.80307@pobox.com>
References: <20060919182724.6355.65746.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke@foo-projects.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:4794 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750740AbWISS6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 14:58:39 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <20060919182724.6355.65746.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Auke Kok <auke-jan.h.kok@intel.com>
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  e1000.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/e1000.c b/e1000.c
> index 6de27ca..6741323 100644
> --- a/e1000.c
> +++ b/e1000.c
> @@ -372,7 +372,7 @@ e1000_dump_regs(struct ethtool_drvinfo *
>  		"      Descriptor minimum threshold size: %s\n"
>  		"      Broadcast accept mode:             %s\n"
>  		"      VLAN filter:                       %s\n"
> -		"      Cononical form indicator:          %s\n"
> +		"      Canonical form indicator:          %s\n"

I had already applied this, but forgotten to push it out to the public 
repository.  Pushed.

	Jeff



