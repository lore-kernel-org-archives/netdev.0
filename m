From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] smsc95xx: Configure pause time to 0xffff when tx
 flow control enabled
Date: Thu, 7 Sep 2017 15:56:58 +0200
Message-ID: <20170907135658.GG11248@lunn.ch>
References: <CE371C1263339941885964188A0225FA3339DB@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, steve.glendinning@shawell.net
To: Nisar.Sayed@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59569 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754964AbdIGN5F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 09:57:05 -0400
Content-Disposition: inline
In-Reply-To: <CE371C1263339941885964188A0225FA3339DB@CHN-SV-EXMX03.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 07, 2017 at 06:51:37AM +0000, Nisar.Sayed@microchip.com wrote:
> From: Nisar Sayed <Nisar.Sayed@microchip.com>
> 
> Configure pause time to 0xffff when tx flow control enabled

Hi Nisar

You should explain the 'Why' in the commit message. Why do we want a
pause time of 0xffff?

      Andrew
