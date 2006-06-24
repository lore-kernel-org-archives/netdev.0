From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: hostapd patch for d80211
Date: Fri, 23 Jun 2006 19:17:54 -0700
Message-ID: <20060624021754.GB9583@jm.kir.nu>
References: <200606191107.34602.mb@bu3sch.de> <20060623201933.59578ecc@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org,
	Alexander Tsvyashchenko <lists@ndl.kiev.ua>,
	Francois Barre <francois.barre@gmail.com>,
	Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.genealogia.fi ([194.100.116.229]:4577 "EHLO
	mail2.genealogia.fi") by vger.kernel.org with ESMTP id S933182AbWFXCSk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 22:18:40 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060623201933.59578ecc@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 08:19:33PM +0200, Jiri Benc wrote:

> This patch allows devicescape driver in hostapd to work with recent d80211.
> No manipulation with network interfaces is needed anymore - hostapd even
> switches the interface to AP mode automatically now. Just modprobe
> bcm43xx-d80211, run hostapd and enjoy :-)

Thanks! Unfortunately, I have been stuck with couple of other projects
lately and have been unable to keep up to date with all changes in
wireless-dev. Anyway, I'm hoping to do some more merging next week and
I'll add this to the list. I think that a similar change was already in
my pending merge queue from Devicescape, but anyway, either this patch
or something similar will end up into hostapd repository.

-- 
Jouni Malinen                                            PGP id EFC895FA
