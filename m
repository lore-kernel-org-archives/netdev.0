From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] net/smsc911x: add device tree probe support
Date: Fri, 29 Jul 2011 10:26:29 -0600
Message-ID: <20110729162629.GI11164@ponder.secretlab.ca>
References: <1311587040-8988-1-git-send-email-shawn.guo@linaro.org>
 <20110725213723.GI26735@ponder.secretlab.ca>
 <20110726010154.GG21641@S2100-06.ap.freescale.net>
 <alpine.LFD.2.00.1107252105561.12766@xanadu.home>
 <20110726013026.GH21641@S2100-06.ap.freescale.net>
 <alpine.LFD.2.00.1107252222540.12766@xanadu.home>
 <20110729023626.GB1946@S2100-06.ap.freescale.net>
 <20110729154723.GC11164@ponder.secretlab.ca>
 <20110729160343.GA2241@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>, patches@linaro.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62737 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228Ab1G2Q0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 12:26:32 -0400
Received: by gyh3 with SMTP id 3so2639983gyh.19
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 09:26:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110729160343.GA2241@S2100-06.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 30, 2011 at 12:03:44AM +0800, Shawn Guo wrote:
> On Fri, Jul 29, 2011 at 09:47:23AM -0600, Grant Likely wrote:
> > On Fri, Jul 29, 2011 at 10:36:26AM +0800, Shawn Guo wrote:
> > > Since I do not get any suggestion here, I'm going to follow the driver
> > > name to use '911' as the model number.  Please tell me if there is any
> > > better one.
> > 
> > What is the manufacturer part name?  lan9111 or lan91c11?  The
> > manufacturer's documented part number is almost always preferred.
> > 
> I just posted the v2 of the patch, and chose to use 'smsc,lan9115'
> which is the first model supported in the driver.  This is the same
> approach I used with i.mx device bindings.

You haven't answered the question.

g.

