From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 4/4] net: smsc911x: Move interrupt allocation to open/stop
Date: Sun, 4 Sep 2016 04:45:46 +0200
Message-ID: <20160904024546.GA8197@lunn.ch>
References: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
 <1472760909-19688-5-git-send-email-jeremy.linton@arm.com>
 <2317c7ce-9d44-7f89-9006-ed05041a9e87@cogentembedded.com>
 <b8978be5-fd24-6aad-8503-3868337a9934@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeremy Linton <jeremy.linton@arm.com>, netdev@vger.kernel.org,
        steve.glendinning@shawell.net, will.deacon@arm.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34684 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753100AbcIDDYG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Sep 2016 23:24:06 -0400
Content-Disposition: inline
In-Reply-To: <b8978be5-fd24-6aad-8503-3868337a9934@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >   Hmm, I didn't see where this code got moved to...
> 
>    Ah, it's the duplicated code... you should've either explicitly
> stated that in the change log or done this in a separate patch, I
> think.

Hi Sergei

Maybe you should read the comments I made :-)

      Andrew
