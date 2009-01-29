From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Fri, 30 Jan 2009 00:10:14 +0100
Message-ID: <200901300010.15747.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <20090129222247.GA13861@xw6200.broadcom.net> <alpine.DEB.2.00.0901291730030.5149@parag-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Parag Warudkar <parag.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:45222 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753306AbZA2XKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 18:10:35 -0500
In-Reply-To: <alpine.DEB.2.00.0901291730030.5149@parag-desktop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 29 January 2009, Parag Warudkar wrote:
> 
> On Thu, 29 Jan 2009, Matt Carlson wrote:
> 
> > FWIW, I can suspend and resume using the latest linux-2.6 kernel
> > on a machine with a similar chip here.  The problem doesn't seem to
> > affect all Broadcom devices.
> 
> It is failing for me on HP xw6600 workstation, if that helps in any way.

Hm, I have an xw4600 nearby, will try tomorrow.

Thanks,
Rafael
