From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: Re: [PATCH 2/2] NetXen: Updates for register access routines
Date: Fri, 18 May 2007 17:00:45 +0530
Message-ID: <200705181700.45421.mithlesh@netxen.com>
References: <200705171353.l4HDr9eb023094@dut39.unminc.com> <464CF7A0.2090604@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:51867 "EHLO
	svr68.ehostpros.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306AbXERLik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 07:38:40 -0400
In-Reply-To: <464CF7A0.2090604@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 18 May 2007 06:17, Jeff Garzik wrote:
> Mithlesh Thukral wrote:
> > NetXen: Changes related to registers and their access routines
> > This patch updates the various access routines to access different
> > control and status settings present in different register locations.
> > This will fix problems related to working of different ports in
> > multi Port card.
> >
> > Signed-off by: Milan Bag <mbag@netxen.com>
> > Signed-off by: Adhiraj Joshi <adhiraj@netxen.com>
> > Acked-by: Mithlesh Thukral <mithlesh@netxen.com>
> > ---
> >  drivers/net/netxen/netxen_nic.h      |   96 ++++++++++---------------
> >  drivers/net/netxen/netxen_nic_hw.h   |   65 +++-------------
> >  drivers/net/netxen/netxen_nic_init.c |   17 ++--
> >  3 files changed, 65 insertions(+), 113 deletions(-)
>
> not applied.  This patch removes a bunch of endianness changes.
Ok. I will take care of these changes in the next patchset that i submit.
Thanks for applying the first patch.

--
Mithlesh Thukral
