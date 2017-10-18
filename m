From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [iproute2] regression in ss output
Date: Wed, 18 Oct 2017 07:17:30 -0700
Message-ID: <1508336250.31614.119.camel@edumazet-glaptop3.roam.corp.google.com>
References: <AM4PR0901MB125261BF480B49D2BA2DF46BCC480@AM4PR0901MB1252.eurprd09.prod.outlook.com>
         <20171016103320.GP11332@orbyte.nwl.cc>
         <AM4PR0901MB12527C55F04814777A0E6849CC4F0@AM4PR0901MB1252.eurprd09.prod.outlook.com>
         <20171016142807.47825131@xeon-e3>
         <1508205636.31614.81.camel@edumazet-glaptop3.roam.corp.google.com>
         <20171016194958.669625db@xeon-e3>
         <AM4PR0901MB1252D66A440ACA247AD32DF4CC4D0@AM4PR0901MB1252.eurprd09.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Humberto Alves <hjalves@live.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:49429 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750775AbdJRORd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 10:17:33 -0400
Received: by mail-pf0-f174.google.com with SMTP id i5so4063315pfe.6
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 07:17:32 -0700 (PDT)
In-Reply-To: <AM4PR0901MB1252D66A440ACA247AD32DF4CC4D0@AM4PR0901MB1252.eurprd09.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-10-18 at 14:08 +0000, Humberto Alves wrote:
> Looks perfect to me. Thanks!
> 
> On 10/17/2017 03:49 AM, Stephen Hemminger wrote:

> > 
> > What about
> > 	*:80	<< both IPV6 and IPV4
> > 	[::]:80	<< IPV6_ONLY
> > 	0.0.0.0:80  << IPV4_ONLY
> > 
> 

Yes, I missed your email Stephen, this looks a nice idea. Thanks !
