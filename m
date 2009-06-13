From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
	configuration.
Date: Sat, 13 Jun 2009 18:10:39 +0100
Message-ID: <20090613171039.GC16775@opensource.wolfsonmicro.com>
References: <20090612105019.GA21599@sirena.org.uk> <20090612.043350.38954875.davem@davemloft.net> <20090612122431.GA8861@rakim.wolfsonmicro.main> <20090612.170157.205072127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mfuzzey@gmail.com, bhutchings@solarflare.com, nico@cam.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:50650 "EHLO
	opensource2.wolfsonmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754194AbZFMRKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 13:10:38 -0400
Content-Disposition: inline
In-Reply-To: <20090612.170157.205072127.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 12, 2009 at 05:01:57PM -0700, David Miller wrote:
> From: Mark Brown <broonie@opensource.wolfsonmicro.com>

> > OpenFirmware works well enough on the platforms that use it but it's far
> > from universal.

> Sounds like an argument for it being more-so :-)

It'd be nice if it were; one of my problems with OpenFirmware right now
is that it just makes for more work since it just winds up meaning we
have to do platform data two ways.  If we made a decision to move to
using OpenFirmware more consistently this would be less of an issue.
