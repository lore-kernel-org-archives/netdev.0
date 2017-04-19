From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next]smsc911x: Adding support for Micochip LAN9250
 Ethernet controller
Date: Wed, 19 Apr 2017 04:24:31 +0200
Message-ID: <20170419022431.GA20301@lunn.ch>
References: <C3C28FB10418274EB7FD7C2B85C796A44124623F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com, steve.glendinning@shawell.net,
        Ravi.Hegde@microchip.com, Woojung.Huh@microchip.com
To: David.Cai@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33984 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754738AbdDSCYg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 22:24:36 -0400
Content-Disposition: inline
In-Reply-To: <C3C28FB10418274EB7FD7C2B85C796A44124623F@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 19, 2017 at 12:29:45AM +0000, David.Cai@microchip.com wrote:
> Attached is a patch which adding support for Microchip LAN9250 Ethernet controller.

Hi David

It looks like your mail system mangled your patch. Please use git
send-email.

> 
> Thanks,
> 
> =====================
> David Cai
> Principle Software Engineer
> Microchip Technology Inc.
> =====================
> 
> Signed-off-by: David Cai <david.cai@microchip.com>
> ---

You should probably also read the SubmittingPatches Documentation.

Everything before the --- is included in the commit log.

	   Andrew
