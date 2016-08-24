From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/4] net: phy: Register header file for Microsemi PHYs.
Date: Wed, 24 Aug 2016 10:15:33 -0700
Message-ID: <b0fe05bc-d6c4-0692-44ba-69ff8db3026a@gmail.com>
References: <646450A91FAED74E85C6E9C4D6E936A14533665A@avsrvexchmbx1.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Allan Nielsen <Allan.Nielsen@microsemi.com>,
        "Andrew Lunn (andrew@lunn.ch)" <andrew@lunn.ch>
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35169 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754132AbcHXRPt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 13:15:49 -0400
Received: by mail-pa0-f66.google.com with SMTP id cf3so1503540pad.2
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 10:15:35 -0700 (PDT)
In-Reply-To: <646450A91FAED74E85C6E9C4D6E936A14533665A@avsrvexchmbx1.microsemi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2016 04:58 AM, Raju Lakkaraju wrote:
> From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> This is Microsemi's VSC 85xx PHY register definitions header file.

Please keep these register definitions local to the code using them
unless they are shared between multiple drivers.
-- 
Florian
