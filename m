From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net headers: cleanup dcbnl.h
Date: Sun, 01 Mar 2009 00:20:11 -0800 (PST)
Message-ID: <20090301.002011.75128637.davem@davemloft.net>
References: <20090227200136.31557.53143.stgit@localhost.localdomain>
	<20090227211305.GA12654@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christopher.leech@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38392
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751289AbZCAIUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 03:20:30 -0500
In-Reply-To: <20090227211305.GA12654@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri, 27 Feb 2009 22:13:05 +0100

> On Fri, Feb 27, 2009 at 12:01:36PM -0800, Chris Leech wrote:
> > 1) add an include for <linux/types.h>
> > 2) change dcbmsg.dcb_family from unsigned char to __u8 to be more
> >    consistent with use of kernel types
> > 
> > Signed-off-by: Chris Leech <christopher.leech@intel.com>
> Thanks Chris.
> 
> Acked-by: Sam Ravnborg <sam@ravnborg.org>

Applied.
