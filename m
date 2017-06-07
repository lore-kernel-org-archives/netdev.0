From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/9] net: mvmdio: use GENMASK for masks
Date: Wed, 7 Jun 2017 12:24:40 -0700
Message-ID: <57ec3539-2271-bed1-4ed6-cfe02827d607@gmail.com>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
 <20170607083810.30922-4-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36577 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752428AbdFGTYw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 15:24:52 -0400
Received: by mail-wm0-f65.google.com with SMTP id k15so4011948wmh.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 12:24:51 -0700 (PDT)
In-Reply-To: <20170607083810.30922-4-antoine.tenart@free-electrons.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2017 01:38 AM, Antoine Tenart wrote:
> Cosmetic patch to use the GENMASK helper for masks.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
