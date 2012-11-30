From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless 2012-11-30
Date: Fri, 30 Nov 2012 14:07:03 -0500
Message-ID: <20121130190702.GC2355@tuxdriver.com>
References: <20121130182459.GB2355@tuxdriver.com>
 <20121130.134018.1859855439413083920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121130.134018.1859855439413083920.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 30, 2012 at 01:40:18PM -0500, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Fri, 30 Nov 2012 13:25:00 -0500
> 
> > I have a couple of stragglers intended for 3.7...
> > 
> > The iwlwifi patch fixes a bug in CCK basic rate calculations.
> > 
> > The mac80211 patch removes an unnecessary function call that was
> > generating a lot of log SPAM.
> 
> Pulled, thanks John.
> 
> I want to warn you ahead of time that these might not make it.

Yes, I suspect that might be the case -- but it won't make it if I
don't send it... :-)

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
