From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-next-2.6 2008-07-02
Date: Mon, 7 Jul 2008 09:15:02 -0400
Message-ID: <20080707131502.GD5457@tuxdriver.com>
References: <20080630215651.GA666@tuxdriver.com> <20080702193710.GA4682@tuxdriver.com> <20080702202653.GA10719@tuxdriver.com> <20080705.214752.85024966.davem@davemloft.net> <1ba2fa240807060007i572d054va60aa16b41cadce3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tomas Winkler <tomasw@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4408 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750804AbYGGNiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 09:38:04 -0400
Content-Disposition: inline
In-Reply-To: <1ba2fa240807060007i572d054va60aa16b41cadce3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 06, 2008 at 10:07:42AM +0300, Tomas Winkler wrote:
> On Sun, Jul 6, 2008 at 7:47 AM, David Miller <davem@davemloft.net> wrote:
> > From: "John W. Linville" <linville@tuxdriver.com>
> > Date: Wed, 2 Jul 2008 16:26:53 -0400
> >
> >> Here is another slew of updates for 2.6.27.  The bulk of this batch is
> >> for iwlwifi, with some mac80211 and other bits thrown-in.
> >>
> >> Let me know if there are problems!
> >
> > Pulled and pushed back out to net-next-2.6, thanks.
> >
> > Here are some warnings I noticed during an allmodconfig build
> > on sparc64, please fix:
> >
> > drivers/net/wireless/hostap/hostap_hw.c:3422: warning: 'prism2_suspend' defined but not used
> > drivers/net/wireless/iwlwifi/iwl-rfkill.c:114: warning: label 'freed_rfkill' defined but not used
> 
> John what happened to to those patches?
> http://marc.info/?l=linux-wireless&m=121489830307988&w=2
> http://marc.info/?l=linux-wireless&m=121481826531792&w=2

They were posted after this round of patches.  I still have them.

John
-- 
John W. Linville
linville@tuxdriver.com
