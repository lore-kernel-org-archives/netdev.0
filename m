From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [2.6 patch] schedule eepro100.c for removal
Date: Fri, 3 Feb 2006 17:18:58 -0500
Message-ID: <20060203221858.GA3670@kvack.org>
References: <20060203213234.GS4408@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946008AbWBCWXa@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060203213234.GS4408@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Where's the hunk to make the eepro100 driver spew messages about being 
obsolete out upon loading?

		-ben

On Fri, Feb 03, 2006 at 10:32:34PM +0100, Adrian Bunk wrote:
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> ---
> 
> This patch was already sent on:
> - 18 Jan 2006
> 
> --- linux-2.6.15-mm4-full/Documentation/feature-removal-schedule.txt.old	2006-01-18 08:38:57.000000000 +0100
> +++ linux-2.6.15-mm4-full/Documentation/feature-removal-schedule.txt	2006-01-18 08:39:59.000000000 +0100
> @@ -164,0 +165,6 @@
> +---------------------------
> +
> +What:   eepro100 network driver
> +When:   April 2006
> +Why:    replaced by the e100 driver
> +Who:    Adrian Bunk <bunk@stusta.de>
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
"Ladies and gentlemen, I'm sorry to interrupt, but the police are here 
and they've asked us to stop the party."  Don't Email: <dont@kvack.org>.
