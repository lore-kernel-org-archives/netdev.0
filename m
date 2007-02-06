From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 2.4 0/3] e1000: update to 7.3.20
Date: Tue, 6 Feb 2007 12:29:57 +0100
Message-ID: <20070206112957.GA5087@1wt.eu>
References: <20070206010102.28691.96744.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2272 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258AbXBFLaK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 06:30:10 -0500
Content-Disposition: inline
In-Reply-To: <20070206010102.28691.96744.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Auke,

On Mon, Feb 05, 2007 at 05:01:02PM -0800, Kok, Auke wrote:
> Willy,
> 
> Please pull:
> 
> git-pull git://lost.foo-projects.org/~ahkok/git/linux-2.4 e1000
> 
> to receive an update for the e1000 driver. This updates the e1000
> driver in the 2.4 kernel to version 7.3.20-k4, roughly the equivalent
> of what is in 2.6.20 and the latest of our out-of-tree driver.
> 
> This adds new hardware support and many fixes. Many customers are
> asking us for these updates and the current 2.4 kernel ships a very
> outdated version of the e1000 adapter.
> 
> This patch includes small compatibility headers and code to minimize
> the changes we need to make to our driver and keep it in sync easier
> with the 2.6 kernel version so we can possibly continue to ship
> updates and fixes to this driver with more ease.

Pulled, thanks very much. I'll produce -pre1 shortly so that we can
ensure there's no regression.

> Cheers,
> 
> Auke

Best Regards,
Willy

