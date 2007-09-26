From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 rebased...
Date: Wed, 26 Sep 2007 13:01:16 -0700 (PDT)
Message-ID: <20070926.130116.102631642.davem@davemloft.net>
References: <20070925.233344.43202361.davem@davemloft.net>
	<20070926124649.GC6171@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, akpm@linux-foundation.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48393
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752810AbXIZUBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 16:01:16 -0400
In-Reply-To: <20070926124649.GC6171@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 26 Sep 2007 08:46:49 -0400

> On Tue, Sep 25, 2007 at 11:33:44PM -0700, David Miller wrote:
> 
> > John, one patch didn't go in cleanly after I removed the
> > Z1211 driver.  I put it here for your consideration so it
> > doesn't get lost:
> > 
> > 	http://vger.kernel.org/~davem/0433-Z1211-Fix-TX-status-reports.patch
> > 
> > What probably needs to happen is some other changes that
> > were in z1211 need to go into the non-mac80211 driver and
> > then this patch applies correctly.
> 
> I have that one, so we're fine.  It is a mac80211-specific fix,
> so I think that takes care of it.

Great, thanks to everyone for checking this out.
