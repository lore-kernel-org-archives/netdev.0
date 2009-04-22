From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 1/2] Add an alternative cs89x0 driver
Date: Wed, 22 Apr 2009 15:05:08 +0200
Message-ID: <20090422130508.GL21747@pengutronix.de>
References: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de> <1240387172-21818-2-git-send-email-s.hauer@pengutronix.de> <49EEE6A1.7070407@xenomai.org> <20090422122038.GJ21747@pengutronix.de> <49EF0CB9.8040708@xenomai.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Lennert Buytenhek <kernel@wantstofly.org>,
	Ivo Clarysse <ivo.clarysse@gmail.com>
To: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:33264 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087AbZDVNFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 09:05:11 -0400
Content-Disposition: inline
In-Reply-To: <49EF0CB9.8040708@xenomai.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2009 at 02:25:29PM +0200, Gilles Chanteperdrix wrote:
> Sascha Hauer wrote:
> > On Wed, Apr 22, 2009 at 11:42:57AM +0200, Gilles Chanteperdrix wrote:
> >> Sascha Hauer wrote:
> >>> +MODULE_AUTHOR("Abraham van der Merwe <abraham@2d3d.co.za>");
> >> The 2d3d.co.za domain does not seem to exist.
> > 
> > Ok, I'll just put myself as the module author and leave the credits to
> > Abraham in the header, just removing his email address. I can't find
> > any newer pointers to Abraham besides a facebook profile.
> 
> 123people finds the following addresses:
> abz@clug.org.za
> abz@blio.net
> abz@debian.org

I'll set him on cc in the next round. I changed the module author
nonetheless as it's better when mails regarding this driver go to
me instead of Abraham (who wrote this driver in 2.4 days and probably
has not much interest in it anymore)

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
