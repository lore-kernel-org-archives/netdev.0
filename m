From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 6/9] net: mvmdio: put the poll intervals in the private
 structure
Date: Wed, 7 Jun 2017 12:25:26 -0700
Message-ID: <91aee753-3cd9-78d7-57f7-8b6ed62e23f3@gmail.com>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
 <20170607083810.30922-7-antoine.tenart@free-electrons.com>
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
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34694 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751814AbdFGTZm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 15:25:42 -0400
Received: by mail-wr0-f193.google.com with SMTP id u101so2010943wrc.1
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 12:25:37 -0700 (PDT)
In-Reply-To: <20170607083810.30922-7-antoine.tenart@free-electrons.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2017 01:38 AM, Antoine Tenart wrote:
> Put the two poll intervals (min and max) in the driver's private
> structure. This is needed to add the xmdio support later.
>
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
