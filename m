From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] add mac80211 wireless infrastructure
Date: Sat, 05 May 2007 11:49:06 -0700 (PDT)
Message-ID: <20070505.114906.71553321.davem@davemloft.net>
References: <20070505031749.GA5308@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43062
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754643AbXEEStU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 14:49:20 -0400
In-Reply-To: <20070505031749.GA5308@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 4 May 2007 23:17:49 -0400

> This series adds the mac80211 component.  This is the new wireless
> infrastructure for "softmac"-style wireless hardware.  It originated
> as code contributed by Devicescape, and has been under development by
> the community for well over a year.  Thanks are due especially to Jiri
> Benc and Michael Wu as well as Johannes Berg and a number of other
> contributors who have worked to hammer this into its current form.
> 
> This component was in -mm for most of the 2.6.21 cycle, with few
> reported bugs.  The code is also currently available in Fedora rawhide
> where it has performed well.
> 
> The wireless developers would like this to be considered for merge
> in time for 2.6.22.  Patches for at least one mac80211-based driver
> will follow shortly.

Applied and pushed out to net-2.6, I'll push this stuff to
Linus, thanks a lot!
