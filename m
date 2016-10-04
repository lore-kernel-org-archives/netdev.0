From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next 0/7] xen-netback: guest rx side refactor
Date: Tue, 4 Oct 2016 08:26:01 +0000
Message-ID: <06f09250258a46c4bb8f07835bdb7ad1@AMSPEX02CL03.citrite.net>
References: <1475479872-23717-1-git-send-email-paul.durrant@citrix.com>
 <20161004.005150.162970316361904440.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:55932 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752197AbcJDI0H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 04:26:07 -0400
In-Reply-To: <20161004.005150.162970316361904440.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: 04 October 2016 05:52
> To: Paul Durrant <Paul.Durrant@citrix.com>
> Cc: netdev@vger.kernel.org; xen-devel@lists.xenproject.org
> Subject: Re: [PATCH net-next 0/7] xen-netback: guest rx side refactor
> 
> From: Paul Durrant <paul.durrant@citrix.com>
> Date: Mon, 3 Oct 2016 08:31:05 +0100
> 
> > This series refactors the guest rx side of xen-netback:
> >
> > - The code is moved into its own source module.
> >
> > - The prefix variant of GSO handling is retired (since it is no longer
> >   in common use, and alternatives exist).
> >
> > - The code is then simplified and modifications made to improve
> >   performance.
> 
> This doesn't apply cleanly to net-next, please respin.

Sure. V2 coming up.

  Paul
