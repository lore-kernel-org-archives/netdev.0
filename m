From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v4 08/11] net: mvmdio: add xmdio xsmi support
Date: Wed, 14 Jun 2017 10:03:47 -0700
Message-ID: <7edbef52-ad00-c59f-3cae-eebd1c823c6f@gmail.com>
References: <20170614154911.14510-1-antoine.tenart@free-electrons.com>
 <20170614154911.14510-9-antoine.tenart@free-electrons.com>
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
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33918 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751902AbdFNRDv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 13:03:51 -0400
Received: by mail-qt0-f195.google.com with SMTP id o21so1148819qtb.1
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 10:03:50 -0700 (PDT)
In-Reply-To: <20170614154911.14510-9-antoine.tenart@free-electrons.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2017 08:49 AM, Antoine Tenart wrote:
> This patch adds the xmdio xsmi interface support in the mvmdio driver.
> This interface is used in Ethernet controllers on Marvell 370, 7k and 8k
> (as of now). The xsmi interface supported by this driver complies with
> the IEEE 802.3 clause 45. The xSMI interface is used by 10GbE devices.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Nice!

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
