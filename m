From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v4 09/11] net: mvmdio: simplify the smi read and write
 error paths
Date: Wed, 14 Jun 2017 10:04:06 -0700
Message-ID: <2940b671-3de3-5220-b1fb-496345cc1c19@gmail.com>
References: <20170614154911.14510-1-antoine.tenart@free-electrons.com>
 <20170614154911.14510-10-antoine.tenart@free-electrons.com>
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
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35132 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751816AbdFNREJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 13:04:09 -0400
Received: by mail-qt0-f195.google.com with SMTP id x58so1143121qtc.2
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 10:04:09 -0700 (PDT)
In-Reply-To: <20170614154911.14510-10-antoine.tenart@free-electrons.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2017 08:49 AM, Antoine Tenart wrote:
> Cosmetic patch simplifying the smi read and write error paths. It also
> align their error paths with the ones of the xsmi functions.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
