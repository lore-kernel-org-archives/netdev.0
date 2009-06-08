From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] isdn: patches for 2.6.31 (v2)
Date: Mon, 08 Jun 2009 00:46:06 -0700 (PDT)
Message-ID: <20090608.004606.216852701.davem@davemloft.net>
References: <20090607-patch-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: karsten-keil@t-online.de, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52760
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752272AbZFHHqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 03:46:05 -0400
In-Reply-To: <20090607-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Sun,  7 Jun 2009 21:09:23 +0200 (CEST)

> Dave, Karsten,
> 
> this is the revised version of my patches to the Kernel CAPI subsystem
> I'd like to propose for inclusion in kernel release 2.6.31.
> 
> The first patch of the series, renaming capi_ctr_reseted() to
> capi_ctr_down(), is unchanged.
> 
> The patch to drivers/isdn/capi/capiutil.c has been split in two, one
> adding the kerneldoc comments and the other one, the NULL pointer
> check.
> 
> The last patch to Documentation/isdn/INTERFACE.CAPI has grown another
> capiutil function description, capi_cmd2str().

This all seems very reasonable to me, applied to net-next-2.6

Thanks!
