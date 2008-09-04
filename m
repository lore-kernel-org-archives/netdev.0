From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ne.c fix for hibernate and rmmod oops fix
Date: Thu, 04 Sep 2008 03:48:39 -0400
Message-ID: <48BF92D7.8050304@garzik.org>
References: <20080904030212.GA23493@spacedout.fries.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>,
	Paul Gortmaker <p_gortmaker@yahoo.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Fries <david@fries.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39959 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751331AbYIDHst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 03:48:49 -0400
In-Reply-To: <20080904030212.GA23493@spacedout.fries.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Fries wrote:
> Andrew Morton, 
> 
> This patch is ready to be merged.
> 
> 
> 
> This ne2000 and the previous cr4 problem found when enabling suspend to
> disk on my i486 with a PnP ISA NE2000 and Creative SB Live in the
> trunk of my car.  It is providing in car podcast entertainment.  Must
> be a unique setup.

Please send a correct patch format.  The comments quoted above are all 
that appears when I run the official patch import tools ('git am').

It should be a simple matter of making sure your patch email body starts 
with "Removing the module would cause a kernel oops as 
platform_driver_probe" as described in Documentation/SubmittingPatches.

	Jeff


