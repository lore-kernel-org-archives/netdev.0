From: Olivier Galibert <galibert@pobox.com>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Sat, 5 Jul 2008 14:02:21 +0200
Message-ID: <20080705120221.GC44773@dspnet.fr.eu.org>
References: <486E2260.5050503@garzik.org> <1215178035.10393.763.camel@pmac.infradead.org> <20080704141014.GA23215@mit.edu> <s5habgxloct.wl%tiwai@suse.de> <486E3622.1000900@suse.de> <1215182557.10393.808.camel@pmac.infradead.org> <20080704231322.GA4410@dspnet.fr.eu.org> <s5h4p746am3.wl%tiwai@suse.de> <20080705105317.GA44773@dspnet.fr.eu.org> <486F596C.8050109@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Takashi Iwai <tiwai@suse.de>,
	David Woodhouse <dwmw2@infradead.org>,
	Hannes Reinecke <hare@suse.de>, Theodore Tso <tytso@mit.edu>,
	Jeff Garzik <jeff@garzik.org>,
	David Miller <davem@davemloft.net>, hugh@veritas.com,
	akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dspnet.fr.eu.org ([213.186.44.138]:3188 "EHLO dspnet.fr.eu.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751877AbYGEMCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jul 2008 08:02:23 -0400
Content-Disposition: inline
In-Reply-To: <486F596C.8050109@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 05, 2008 at 01:22:20PM +0200, Andi Kleen wrote:
> Many distribution have some way for separate kernel module packages.
> It's essentially the same problem so it should be already solved
> in some way.

Errr, no.  Modules go in /lib/modules/`uname -r`, so no conflict.

  OG.
