From: David Miller <davem@davemloft.net>
Subject: Re: high latency with TCP connections
Date: Thu, 31 Aug 2006 23:23:24 -0700 (PDT)
Message-ID: <20060831.232324.18304115.davem@davemloft.net>
References: <20060831.165701.104033558.davem@davemloft.net>
	<20060831202309.5caefbff@localhost.localdomain>
	<5640c7e00608312039m752be44ek85f0caa6764df853@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, kuznet@ms2.inr.ac.ru, alex@sectorb.msk.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18314
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750823AbWIAGXY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 02:23:24 -0400
To: ian.mcdonald@jandi.co.nz
In-Reply-To: <5640c7e00608312039m752be44ek85f0caa6764df853@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 1 Sep 2006 15:39:37 +1200

> > > I'm ready to rip out ABC entirely, to be honest.  Or at least
> > > turn it off by default.
> >
> > Turn it off for 2.6.18, by default then evaluate more for 2.6.19
> >
> If it goes out in 2.6.18 there could probably be a good argument for
> going into the stable tree as well... to stop the likes of the JVM
> type issues that users keep hitting (which is fixed or going to be
> fixed by Sun).

I completely agree.
