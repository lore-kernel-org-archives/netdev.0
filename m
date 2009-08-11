From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] MAINTAINERS: Add networking wireless drivers section
Date: Tue, 11 Aug 2009 15:55:46 +0200 (CEST)
Message-ID: <alpine.LRH.2.00.0908111555410.11142@twin.jikos.cz>
References: <Pine.LNX.4.64.0907281753540.28189@ask.diku.dk>  <20090728.103044.179053537.davem@davemloft.net>  <1248804397.18284.5.camel@Joe-Laptop.home>  <20090728.113353.08715297.davem@davemloft.net> <1248806896.18284.14.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, linville@tuxdriver.com,
	julia@diku.dk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754764AbZHKNzw@vger.kernel.org>
In-Reply-To: <1248806896.18284.14.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Jul 2009, Joe Perches wrote:

> > Why not just create a plain "WIRELESS" umbrella entry that contains 
> > all of drivers/net/wireless, net/mac80211, and net/wireless?
> Whatever works for John I suppose. John, do you have a preference?
> I was trying to avoid the "S: Maintained" label
> and was copying the form of this section:
> 
> NETWORKING DRIVERS
> L:	netdev@vger.kernel.org
> W:	http://www.linuxfoundation.org/en/Net
> T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
> S:	Odd Fixes
> F:	drivers/net/

Just out of curiosity, why is drivers/net marked as "Odd fixes" and not 
"Maintained"?

-- 
Jiri Kosina
SUSE Labs
