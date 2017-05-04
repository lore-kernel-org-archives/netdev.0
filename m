From: Florian Westphal <fw@strlen.de>
Subject: Re: [[NET-NEXT]] Added dump function to recognise rpl extension
 header option(63)
Date: Thu, 4 May 2017 14:57:21 +0200
Message-ID: <20170504125721.GF13320@breakpoint.cc>
References: <a712ff423471e02a533650ce6d64dc85@ceid.upatras.gr>
 <af9727bf-9987-1046-c2aa-2a8695447fde@osg.samsung.com>
 <20170504123337.GE13320@breakpoint.cc>
 <20170504125101.GD31463@work.Speedport_W_724V_09011603_05_010>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        Andreas Bardoutsos <bardoutsos@ceid.upatras.gr>,
        netdev <netdev@vger.kernel.org>,
        Michael Richardson <mcr@sandelman.ca>,
        "linux-wpan@vger.kernel.org" <linux-wpan@vger.kernel.org>
To: Stefan Schmidt <stefan@osg.samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:56634 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753400AbdEDM5t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 08:57:49 -0400
Content-Disposition: inline
In-Reply-To: <20170504125101.GD31463@work.Speedport_W_724V_09011603_05_010>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Schmidt <stefan@osg.samsung.com> wrote:
> > The kernel tosses it because the RPL option/RFC says so
> > ('nodes that do not understand this option on a received
> >  packet MUST discard the packet.').
> 
> What we might need is a way to let the kernel know we have a RPL running with
> support for this option. Would that meet your concern?

Sure.
