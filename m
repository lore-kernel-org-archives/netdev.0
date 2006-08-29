From: "Steve Wise" <swise@opengridcomputing.com>
Subject: Re: [PATCH v4 7/7] AMSO1100 Makefiles and Kconfig changes.
Date: Mon, 28 Aug 2006 19:25:36 -0500
Message-ID: <007301c6cb01$aacc2830$020010ac@haggard>
References: <20060803210723.16572.34829.stgit@dell3.ogc.int><20060803210738.16572.74032.stgit@dell3.ogc.int> <adazmdoo3x8.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <openib-general@openib.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:38101 "EHLO
	dell3.ogc.int") by vger.kernel.org with ESMTP id S964946AbWH2AZr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 20:25:47 -0400
To: "Roland Dreier" <rdreier@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sounds good to me.


----- Original Message ----- 
From: "Roland Dreier" <rdreier@cisco.com>
To: "Steve Wise" <swise@opengridcomputing.com>
Cc: <openib-general@openib.org>; <netdev@vger.kernel.org>
Sent: Monday, August 28, 2006 6:07 PM
Subject: Re: [PATCH v4 7/7] AMSO1100 Makefiles and Kconfig changes.


> I'm finally getting around to merging this up, and:
> 
> > --- /dev/null
> > +++ b/drivers/infiniband/hw/amso1100/README
> > @@ -0,0 +1,11 @@
> > +This is the OpenFabrics provider driver for the 
> > +AMSO1100 1Gb RNIC adapter. 
> > +
> > +This adapter is available in limited quantities 
> > +for development purposes from Open Grid Computing.
> > +
> > +This driver requires the IWCM and CMA mods necessary
> > +to support iWARP.
> > +
> > +Contact tom@opengridcomputing.com for more information.
> > +
> 
> I don't think this belongs in the drivers directory.  In fact, is it
> worth having this in the kernel at all?
> 
> How about if I just add a MAINTAINERS entry for amso1100 pointing at
> tom@opengridcomputing.com ?
> 
> - R.
>
