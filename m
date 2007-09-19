From: maximilian attems <max@stro.at>
Subject: Re: bnx2 dirver's firmware images
Date: Wed, 19 Sep 2007 18:51:03 +0200
Message-ID: <20070919165103.GS19918@baikonur.stro.at>
References: <20070918.112337.74737433.davem@davemloft.net> <1190145951.9540.230.camel@dell> <20070919163318.GG6618@stro.at> <20070919.093832.88002774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:2538 "EHLO baikonur.stro.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124AbXISQvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 12:51:33 -0400
Content-Disposition: inline
In-Reply-To: <20070919.093832.88002774.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hello dave,

i appreciate a lot your opinon, but please cool down.
this is not a four spin on your beloved pipe. :)

On Wed, Sep 19, 2007 at 09:38:32AM -0700, David Miller wrote:
> From: maximilian attems <max@stro.at>
> Date: Wed, 19 Sep 2007 18:33:18 +0200
> 
> > we have to strip the firmware for Debian for the upcoming Lenny release.
> 
> Why do you "have to"?  The vendor has given you explicit rights
> to distribute it:
> 
>  * Firmware is:
>  *	Derived from proprietary unpublished source code,
>  *	Copyright (C) 2000-2003 Broadcom Corporation.
>  *
>  *	Permission is hereby granted for the distribution of this firmware
>  *	data in hexadecimal or equivalent format, provided this copyright
>  *	notice is accompanying it.

afair the trouble is that it does not give permission to change
unlike some other gpl or bsd licensed blob.
so it is dfsg non-free and not suitable for main distribution.
 
> This whole firmware stripping thing in debian is beyond rediculious
> and only serves to hurt users.

i'm not of the d-legal department,
but seeing free firmwares would be cool.

-- 
maks

