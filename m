From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/6] e1000: update to 7.0.38-k4
Date: Tue, 23 May 2006 17:22:31 -0400
Message-ID: <44737D17.4060700@pobox.com>
References: <20060523210740.18540.56647.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:12240 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750996AbWEWVWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 17:22:35 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060523210740.18540.56647.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Hi,
> 
> These e1000 patches include a fix for WOL and some driver cleanups:
> 
> [1]: add shutdown handler back to fix WOL
> [2]: remove backslash r debug printfs
> [3]: remove leading and trailing whitespace.
> [4]: Fix date string in Makefile
> [5]: remove changelog in driver
> [6]: bump version to 7.0.38-k4
> 
> 
> Jeff, please pull from:
> 
> git://lost.foo-projects.org/~ahkok/git/netdev-2.6 e1000-7.0.38-k4

pulled


