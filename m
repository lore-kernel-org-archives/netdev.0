From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH 0/4] net: phy: Register header file for Microsemi PHYs.
Date: Fri, 26 Aug 2016 15:52:21 +0530
Message-ID: <20160826102219.GA22159@microsemi.com>
References: <646450A91FAED74E85C6E9C4D6E936A14533665A@avsrvexchmbx1.microsemi.net>
 <b0fe05bc-d6c4-0692-44ba-69ff8db3026a@gmail.com>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>,
        "Andrew Lunn (andrew@lunn.ch)" <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0050.outbound.protection.outlook.com ([104.47.37.50]:22016
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752686AbcHZKWj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 06:22:39 -0400
Content-Disposition: inline
In-Reply-To: <b0fe05bc-d6c4-0692-44ba-69ff8db3026a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

I would like to share these register definitions share between Microsemi multiple drivers.
I refer the existing PHY drivers and follow the similar to "dp83640_reg.h" for register definitions.

Thanks,
Raju. 
On Wed, Aug 24, 2016 at 10:15:33AM -0700, Florian Fainelli wrote:
> EXTERNAL EMAIL
> 
> 
> On 08/24/2016 04:58 AM, Raju Lakkaraju wrote:
> > From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> >
> > This is Microsemi's VSC 85xx PHY register definitions header file.
> 
> Please keep these register definitions local to the code using them
> unless they are shared between multiple drivers.
> --
> Florian
