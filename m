From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2008-08-04
Date: Tue, 05 Aug 2008 01:28:14 -0700 (PDT)
Message-ID: <20080805.012814.215633850.davem@davemloft.net>
References: <20080804193753.GA30345@tuxdriver.com>
	<20080804.150147.78586437.davem@davemloft.net>
	<20080805021710.GA21731@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53872
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754593AbYHEI2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 04:28:14 -0400
In-Reply-To: <20080805021710.GA21731@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 4 Aug 2008 22:17:10 -0400

> On Mon, Aug 04, 2008 at 03:01:47PM -0700, David Miller wrote:
> > I'm holding off on this pull until the list.h changes get so me lkml
> > ACKs.
> 
> Sure, np.  I created a "no-ath9k" branch in case you are feeling
> frisky -- it is the same except for omitting the list.h changes,
> the ath5k pci table change, and the new ath9k driver.
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git no-ath9k
> 
> Hth!

Thanks John.

Due to the powerpc build failures the list.h stuff causes, I'm going
to pull this so I can do a push to Linus tonight.

Although I highly encourare you to get that list.h stuff sorted out
because I'd really like to see ath9k get merged in as that's a useful
device to support for a lot of users.
