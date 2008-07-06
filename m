From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Sun, 06 Jul 2008 13:50:41 +0200
Message-ID: <4870B191.7020808@firstfloor.org>
References: <1215182557.10393.808.camel@pmac.infradead.org>	 <20080704231322.GA4410@dspnet.fr.eu.org> <s5h4p746am3.wl%tiwai@suse.de>	 <20080705105317.GA44773@dspnet.fr.eu.org> <486F596C.8050109@firstfloor.org>	 <20080705120221.GC44773@dspnet.fr.eu.org> <486F6494.8020108@firstfloor.org>	 <1215260166.10393.816.camel@pmac.infradead.org>	 <20080705171316.GA3615@infradead.org>	 <1215291312.3189.88.camel@shinybook.infradead.org>	 <20080706100230.GA21160@infradead.org> <1215341730.10393.931.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	Olivier Galibert <galibert@pobox.com>,
	Takashi Iwai <tiwai@suse.de>, Hannes Reinecke <hare@suse.de>,
	Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>,
	David Miller <davem@davemloft.net>, hugh@veritas.com,
	akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:48663 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532AbYGFLup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 07:50:45 -0400
In-Reply-To: <1215341730.10393.931.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I haven't yet come to a firm conclusion about what to do when we get to
> those drivers; they're a bit of a special case. 

You could just keep them as they are? iirc they work just fine.

-Andi
