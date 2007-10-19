From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip: justification for local port range robustness
Date: Thu, 18 Oct 2007 22:00:35 -0700 (PDT)
Message-ID: <20071018.220035.38690702.davem@davemloft.net>
References: <m3odewh50m.fsf@bandura.englab.brq.redhat.com>
	<20071018083030.05a2aade@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aarapov@redhat.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40493
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752192AbXJSFA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 01:00:26 -0400
In-Reply-To: <20071018083030.05a2aade@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 18 Oct 2007 08:30:30 -0700

> > Justification of the Stephen Hemminger's patches, commit numbers
> >   06393009000779b00a558fd2f280882cc7dc2008
> >   227b60f5102cda4e4ab792b526a59c8cb20cd9f8
> > 
> >   1. Allows using a port range of one single port.
> >   2. Gives back sense of 'remaining' variable.
> > 
> > Signed-off-by: Anton Arapov <aarapov@redhat.com>
> 
> Acked-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied.
