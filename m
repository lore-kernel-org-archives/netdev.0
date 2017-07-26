From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 02/13] net: phy: split out PHY speed and duplex string
 generation
Date: Wed, 26 Jul 2017 15:37:03 -0700
Message-ID: <60968d92-5ad5-04ea-9815-1cb7fa41840c@gmail.com>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
 <E1da0Q6-0007Kv-Mc@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:37617 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751034AbdGZWhH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 18:37:07 -0400
Received: by mail-wr0-f195.google.com with SMTP id 12so15082809wrb.4
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 15:37:07 -0700 (PDT)
In-Reply-To: <E1da0Q6-0007Kv-Mc@rmk-PC.armlinux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2017 07:02 AM, Russell King wrote:
> Other code would like to make use of this, so make the speed and duplex
> string generation visible, and place it in a separate file.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
