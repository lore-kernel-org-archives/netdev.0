From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: pull request: wireless-next 2011-11-28
Date: Tue, 29 Nov 2011 14:54:33 +0100
Message-ID: <1322574873.4110.15.camel@jlt3.sipsolutions.net>
References: <20111128200221.GD2681@tuxdriver.com>
	 <1322554972.4110.0.camel@jlt3.sipsolutions.net>
	 <20111129134243.GB2705@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:33464 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755058Ab1K2Nym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 08:54:42 -0500
In-Reply-To: <20111129134243.GB2705@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-29 at 08:42 -0500, John W. Linville wrote:

> > > Johannes Berg (12):
> > 
> > >       mac80211: use skb list for fragments
> > >       mac80211: move fragment flag adjustment
> > >       mac80211: make TX LED handling independent of fragmentation
> > >       mac80211: transmit fragment list to drivers
> > 
> > Since you included these patches, can you please pick up "mac80211: fix
> > TX warning" relatively quickly? It fixes a harmless but possibly
> > recurring WARN_ON in this code.
> 
> It's already in wireless-next. :-)

Yeah, sorry, I noticed an hour later or so that I'd been checking the
wrong tree (without updating first)

johannes
