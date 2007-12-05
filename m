From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: TCP event tracking via netlink...
Date: Wed, 5 Dec 2007 17:48:43 +0300
Message-ID: <20071205144843.GB2623@2ka.mipt.ru>
References: <20071205.053031.87154402.davem@davemloft.net> <4756B175.5010108@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:48188 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751270AbXLEOtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 09:49:16 -0500
Content-Disposition: inline
In-Reply-To: <4756B175.5010108@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Wed, Dec 05, 2007 at 09:11:01AM -0500, John Heffner (jheffner@psc.edu) wrote:
> >Maybe if we want to get really fancy we can have some more-expensive
> >debug mode where detailed specific events get generated via some
> >macros we can scatter all over the place.  This won't be useful
> >for general user problem analysis, but it will be excellent for
> >developers.
> >
> >Let me know if you think this is useful enough and I'll work on
> >an implementation we can start playing with.
> 
> 
> FWIW, sounds similar to what these guys are doing with SIFTR for FreeBSD:
> http://caia.swin.edu.au/urp/newtcp/tools.html
> http://caia.swin.edu.au/reports/070824A/CAIA-TR-070824A.pdf

And even more similar to this patch from Samir Bellabes of Mandriva:
http://lwn.net/Articles/202255/

-- 
	Evgeniy Polyakov
