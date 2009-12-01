From: Jesper Nilsson <Jesper.Nilsson@axis.com>
Subject: Re: [PATCH] Update embedded copy of ethtool.h from kernel 2.6.30
Date: Tue, 1 Dec 2009 16:54:41 +0100
Message-ID: <20091201155441.GJ5694@axis.com>
References: <20091201151750.GG5694@axis.com> <1259680878.2831.3.camel@achroite.uk.solarflarecom.com> <20091201154246.GH5694@axis.com> <1259682754.2831.11.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from krynn.se.axis.com ([193.13.178.10]:36689 "EHLO
	krynn.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbZLAQaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 11:30:00 -0500
Content-Disposition: inline
In-Reply-To: <1259682754.2831.11.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 01, 2009 at 04:52:34PM +0100, Ben Hutchings wrote:
> On Tue, 2009-12-01 at 16:42 +0100, Jesper Nilsson wrote:
> > On Tue, Dec 01, 2009 at 04:21:18PM +0100, Ben Hutchings wrote:
> > > On Tue, 2009-12-01 at 16:17 +0100, Jesper Nilsson wrote:
> That's the correct repository.  It is possible that the extra static
> information needed to serve it over HTTP is not up-to-date.  Try using
> git protocol instead?

Yep, that was it, looks much better now. Thanks.

> Ben.

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com
