From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/5] net: phy: split out 10G genphy support
Date: Thu, 1 Jun 2017 10:17:38 -0700
Message-ID: <71dc9f1c-a1ca-ce57-17ac-da8855003dbc@gmail.com>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJR-00043n-ON@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35038 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751155AbdFARRl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 13:17:41 -0400
Received: by mail-qk0-f196.google.com with SMTP id v195so6531634qka.2
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 10:17:40 -0700 (PDT)
In-Reply-To: <E1dGNJR-00043n-ON@rmk-PC.armlinux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2017 03:26 AM, Russell King wrote:
> Move the old 10G genphy support to sit beside the new clause 45 library
> functions, so all the 10G phy code is together.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
