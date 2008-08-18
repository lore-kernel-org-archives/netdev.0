From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Sun, 17 Aug 2008 23:13:39 -0700 (PDT)
Message-ID: <20080817.231339.57073652.davem@davemloft.net>
References: <20080818043645.GA32755@gondor.apana.org.au>
	<20080817.221314.193687456.davem@davemloft.net>
	<200808180908.12552.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54762
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751149AbYHRGNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 02:13:40 -0400
In-Reply-To: <200808180908.12552.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Fedoryshchenko <denys@visp.net.lb>
Date: Mon, 18 Aug 2008 09:08:12 +0300

> On Monday 18 August 2008, David Miller wrote:
> > All of this is now pushed to net-2.6 on kernel.org
> So i can build & test net-2.6 from git? :-)

Should be able to, yes :-)
