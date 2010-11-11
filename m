From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH 00/10] cxgb4vf: a number of bug fixes and minor cleanup
Date: Thu, 11 Nov 2010 09:40:48 -0800
Message-ID: <201011110940.48233.leedom@chelsio.com>
References: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com> <20101111.093315.183049721.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12692 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755117Ab0KKRk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 12:40:58 -0500
In-Reply-To: <20101111.093315.183049721.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: David Miller <davem@davemloft.net>
| Date: Thursday, November 11, 2010 09:33 am
| 
| From: Casey Leedom <leedom@chelsio.com>
| Date: Wed, 10 Nov 2010 18:01:33 -0800
| 
| > The following patch set includes a number of bug fixes and some
| > minor cleanup for the cxgb4vf network driver.  If there are any
| > problems with formatting, etc. of the patch set please just reject
| > the patch set and kick my butt ― I'm still a novice at putting these
| > together!
| 
| This is a mix of bug fixes (which would be appropriate for net-2.6)
| and also changes like cleanups and minor feature adds which are not
| appropriate in net-2.6
| 
| Please split them up.
| 
| I'd suggest sending out only the real bug fixes so I can quickly get
| them into net-2.6, and then later you can submit the cleanups and
| feature-adds realtive to the net-2.6 stuff.

  Okay, sorry, I didn't know what the policies were.  It'll take a bit for me to 
wrangle "git send-email" into doing this.  Two new patch sets coming before the 
end of the day!

Casey
