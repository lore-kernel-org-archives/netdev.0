From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v3 04/10] net: dsa: Move ports assignment closer
 to error checking
Date: Sun, 15 Jan 2017 13:17:11 +0300
Message-ID: <f67f9157-47fb-bb55-a248-de63b6d9d851@cogentembedded.com>
References: <20170114214713.28109-1-f.fainelli@gmail.com>
 <20170114214713.28109-5-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        "moderated list:ARM SUB-ARCHITECTURES"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>,
        gregkh@linuxfoundation.org
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:35951 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750809AbdAOKRP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 05:17:15 -0500
Received: by mail-lf0-f52.google.com with SMTP id z134so60756289lff.3
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 02:17:14 -0800 (PST)
In-Reply-To: <20170114214713.28109-5-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 1/15/2017 12:47 AM, Florian Fainelli wrote:

> Move the assignment of ports in _dsa_register_switch() closer to where
> it is checked, no functional change. Re-order declarations to be

    "Be" not needed.

> preserve the inverted christmas tree style.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
[...]

MBR, Sergei
