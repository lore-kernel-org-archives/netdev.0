From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 00/11] Start adding support for mv88e6390 family
Date: Sun, 13 Nov 2016 21:24:03 +0100
Message-ID: <20161113202403.GB18258@lunn.ch>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
 <20161113.004859.749028544003333521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37046 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932549AbcKMUYG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 15:24:06 -0500
Content-Disposition: inline
In-Reply-To: <20161113.004859.749028544003333521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 13, 2016 at 12:48:59AM -0500, David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Fri, 11 Nov 2016 03:53:32 +0100
> 
> > This is the first patchset implementing support for the mv88e6390
> > family.  This is a new generation of switch devices and has numerous
> > incompatible changes to the registers. These patches allow the switch
> > to the detected during probe, and makes the statistics unit work.
> > 
> > These patches are insufficient to make the mv88e6390 functional. More
> > patches will follow.
> 
> Andrew, this series doesn't apply cleanly to net-next, so you'll
> need to respin.

Hi David

I'm happy to respin, but i'm wondering why the don't apply.

What seems to be the issue is you said you have accepted:

[PATCH net-next 0/2] Fixes for port refactoring
https://marc.info/?l=linux-netdev&m=147880114928996&w=1

Yet i don't see these in net-next. And i based this patchset on a tree
which included the fixes. Hence they are not applying.

Have the fixes really been accepted?

Thanks
	Andrew


 
