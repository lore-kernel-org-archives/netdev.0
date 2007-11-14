From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/05] ipv6: RFC4214 Support (3)
Date: Tue, 13 Nov 2007 21:05:13 -0800 (PST)
Message-ID: <20071113.210513.157206334.davem@davemloft.net>
References: <473371B3.5030908@yahoo.com>
	<4734FCEF.3080301@yahoo.com>
	<20071113125312.4c4d1391@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: osprey67@yahoo.com, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40376
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750784AbXKNFFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:05:14 -0500
In-Reply-To: <20071113125312.4c4d1391@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 13 Nov 2007 12:53:12 -0800

> On Fri, 09 Nov 2007 16:35:59 -0800
> osprey67 <osprey67@yahoo.com> wrote:
> 
> > From: Fred L. Templin <fred.l.templin@boeing.com>
> > 
> > This message attaches the combined diffs from
> > messages 01/05 through 04/05. This file should be
> > suitable for use with the patch utility.
> > 
> > Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
> > 
> 
> Isn't increasing the size of struct ip_tunnel_parm
> going to cause kernel ABI changes?

Yeah it is, unfortunately.
