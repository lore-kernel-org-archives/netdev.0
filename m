From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: phy: smsc: Implement PHY statistics
Date: Fri, 2 Jun 2017 16:44:28 -0700
Message-ID: <57f35638-8cbc-c815-2548-fca819257a94@gmail.com>
References: <1496438670-30829-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Chris Healy <cphealy@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35533 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdFBXof (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 19:44:35 -0400
Received: by mail-wr0-f196.google.com with SMTP id g76so2428711wrd.2
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 16:44:35 -0700 (PDT)
In-Reply-To: <1496438670-30829-1-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/2017 02:24 PM, Andrew Lunn wrote:
> Most of the PHYs supported by the SMSC driver have a counter of symbol
> errors. This is 16 bit wide and wraps around when it reaches its
> maximum value.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
