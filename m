From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next-2.6 2010-12-08
Date: Fri, 10 Dec 2010 10:01:41 -0800 (PST)
Message-ID: <20101210.100141.183065894.davem@davemloft.net>
References: <20101208210432.GH2423@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45807
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755146Ab0LJSBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 13:01:14 -0500
In-Reply-To: <20101208210432.GH2423@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 8 Dec 2010 16:04:32 -0500

> Here is the latest batch of updates intended for 2.6.38.  It also
> includes my last wireless-2.6 pull request that you just added
> to net-2.6.
> 
> This includes the usual batch of drivers updates, with ath9k and
> iwlwifi as the usual standouts.  This also includes some mac80211
> documentation updates from Johannes, and a flurry of ath5k updates
> from Nick.  This also includes a collection of bluetooth updates by
> way of Gustavo, a couple of libertas updates, some more work on b43
> N-phy support, and a variety of other patches.

So I pulled this in.

Since I did the net-2.6 --> net-next-2.6 merge first, I ended up having
to deal with the ar9003_eeprom.c conflicts in the ath9k driver even
though you took care of that as well in this tree of your's.

But it was a good gut check since we both resolved the conflict pretty
much the same way, so I have confidence in the merge resolution :-)

Anyways, please take a look at net-next-2.6 and double-check what I
did.

Thanks!
