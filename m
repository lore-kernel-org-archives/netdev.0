From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-next-2.6 2010-12-08
Date: Fri, 10 Dec 2010 13:20:46 -0500
Message-ID: <20101210182045.GD4296@tuxdriver.com>
References: <20101208210432.GH2423@tuxdriver.com>
 <20101210.100141.183065894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54168 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365Ab0LJSaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 13:30:06 -0500
Content-Disposition: inline
In-Reply-To: <20101210.100141.183065894.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 10, 2010 at 10:01:41AM -0800, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Wed, 8 Dec 2010 16:04:32 -0500
> 
> > Here is the latest batch of updates intended for 2.6.38.  It also
> > includes my last wireless-2.6 pull request that you just added
> > to net-2.6.
> > 
> > This includes the usual batch of drivers updates, with ath9k and
> > iwlwifi as the usual standouts.  This also includes some mac80211
> > documentation updates from Johannes, and a flurry of ath5k updates
> > from Nick.  This also includes a collection of bluetooth updates by
> > way of Gustavo, a couple of libertas updates, some more work on b43
> > N-phy support, and a variety of other patches.
> 
> So I pulled this in.
> 
> Since I did the net-2.6 --> net-next-2.6 merge first, I ended up having
> to deal with the ar9003_eeprom.c conflicts in the ath9k driver even
> though you took care of that as well in this tree of your's.
> 
> But it was a good gut check since we both resolved the conflict pretty
> much the same way, so I have confidence in the merge resolution :-)
> 
> Anyways, please take a look at net-next-2.6 and double-check what I
> did.

Looks good to me...thanks!

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
