From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v4 05/11] net: mvmdio: introduce an ops structure
Date: Wed, 14 Jun 2017 10:02:03 -0700
Message-ID: <cb758687-8516-3f7e-b28a-2b2400464f4f@gmail.com>
References: <20170614154911.14510-1-antoine.tenart@free-electrons.com>
 <20170614154911.14510-6-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33576 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751714AbdFNRCH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 13:02:07 -0400
Received: by mail-qt0-f193.google.com with SMTP id w1so1134516qtg.0
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 10:02:06 -0700 (PDT)
In-Reply-To: <20170614154911.14510-6-antoine.tenart@free-electrons.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2017 08:49 AM, Antoine Tenart wrote:
> Introduce an ops structure to add an indirection on the is_done
> function, as this is needed to add the xMDIO support later.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
