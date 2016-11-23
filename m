From: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: egress all frames
Date: Wed, 23 Nov 2016 10:56:22 +0100
Message-ID: <20161123095622.GA12698@gruene.netmodule.intranet>
References: <20161122103944.31381-1-stefan.eichenberger@netmodule.com>
 <20161122150330.GE2691@lunn.ch>
 <20161122183732.GD13973@gruene.netmodule.intranet>
 <20161122190206.GE14947@lunn.ch>
 <87zikr40w2.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Lunn <andrew@lunn.ch>,
        Stefan Eichenberger <eichest@gmail.com>,
        <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.netmodule.com ([194.29.26.242]:12902 "EHLO
        webmail.netmodule.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934143AbcKWJ43 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 04:56:29 -0500
Content-Disposition: inline
In-Reply-To: <87zikr40w2.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vivien

On Tue, Nov 22, 2016 at 05:15:25PM -0500, Vivien Didelot wrote:
> Hi Andrew, Stefan,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > What you might find useful is
> >
> > https://github.com/vivien/linux.git 161b96bd7d16d21b0f046c935b70c3b2d277ccc2
> >
> > although it might need some changes for recent commits.
> >
> > With that, you can see deeper into the switches registers.
> 
> FYI, I have rebased it on top of the latest net-next (f9aa9dc7d2d0):
> 
>     https://github.com/vivien/linux.git dsa/dev
> 

Perfect that is really helpful, thanks a lot!
Stefan
