From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V2 3/3] net: bgmac: use PHY subsystem for initializing PHY
Date: Tue, 31 Jan 2017 10:06:34 -0800
Message-ID: <1daad20f-f794-3c10-d020-fa08dbf228c2@gmail.com>
References: <20170128210832.26174-1-zajec5@gmail.com>
 <20170128210832.26174-4-zajec5@gmail.com>
 <20170131.130429.1477789092223900995.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jon.mason@broadcom.com, nbd@openwrt.org, netdev@vger.kernel.org,
        rafal@milecki.pl
To: David Miller <davem@davemloft.net>, zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35288 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751530AbdAaSGl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:06:41 -0500
Received: by mail-pf0-f196.google.com with SMTP id f144so29048185pfa.2
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 10:06:41 -0800 (PST)
In-Reply-To: <20170131.130429.1477789092223900995.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2017 10:04 AM, David Miller wrote:
> 
> This entire series is being held up because there is still questions about
> whether this is programming the internal PHYs and therefore whether the
> code should be placed elsewhere.
> 
> Can we please move the discussion forward?

The patches are good as-is, we can resolve the PHY programming later on
when we have figured out the details of the 4749 chip we derailed on.

Thanks
-- 
Florian
