From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH 0/4] net: phy: Register header file for Microsemi PHYs.
Date: Thu, 8 Sep 2016 14:31:28 +0530
Message-ID: <20160908090126.GA4134@microsemi.com>
References: <646450A91FAED74E85C6E9C4D6E936A14533665A@avsrvexchmbx1.microsemi.net>
 <b0fe05bc-d6c4-0692-44ba-69ff8db3026a@gmail.com>
 <20160826102219.GA22159@microsemi.com>
 <20160826134028.GE25046@lunn.ch>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0049.outbound.protection.outlook.com ([104.47.33.49]:19280
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932411AbcIHJR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 05:17:26 -0400
Content-Disposition: inline
In-Reply-To: <20160826134028.GE25046@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thank you for review the code and given valuable comments.
Other driver is not yet complete.

I accepted your review comment. I will keep all Register defined MACRO's in 
mscc.c file.

Thanks,
Raju.
On Fri, Aug 26, 2016 at 03:40:28PM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> > I would like to share these register definitions share between
> > Microsemi multiple drivers.
> 
> Hi Raju
> 
> Please post a patch which does this, i.e. modifies multiple drivers to
> share the header file.
> 
> However, just be aware, if it turns out these multiple drivers are
> very similar, we might actually ask you to merge them into one driver.
> 
>      Andrew
