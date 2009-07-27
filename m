From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Add some function overview comments in tcp_input.c
Date: Mon, 27 Jul 2009 14:48:20 +0200
Message-ID: <20090727124820.GA18785@basil.fritz.box>
References: <20090724094719.GA19200@basil.fritz.box> <20090726.192321.257422911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:39882 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753374AbZG0MsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 08:48:24 -0400
Content-Disposition: inline
In-Reply-To: <20090726.192321.257422911.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 26, 2009 at 07:23:21PM -0700, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Fri, 24 Jul 2009 11:47:19 +0200
> 
> > Add some function overview comments in tcp_input.c
> > 
> > Only partial so far. I didn't attempt to accurately comment
> > the SACK machinery and the congestion state machine. 
> > 
> > I also fixed the grammar in one or two other comments
> > (but still trying to keep the authentic "ANK language" @)
> > 
> > No code changes.
> > 
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> Most of your comments sound exactly the same as what I
> hear when I say the function's name out loud.

Ok, not all, but fair enough.  Commenting existing code
was a folly anyways.

-Andi
