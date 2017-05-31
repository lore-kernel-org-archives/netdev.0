From: Florian Fainelli <florian.fainelli@broadcom.com>
Subject: Re: [PATCH net-next] net: phy: use of_mdio_parse_addr
Date: Wed, 31 May 2017 13:01:21 -0700
Message-ID: <a63ef3e1-7cca-525a-9af8-d376d769a19a@broadcom.com>
References: <1496259810-3602-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com
To: Jon Mason <jon.mason@broadcom.com>, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:32983 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751141AbdEaUB0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 16:01:26 -0400
Received: by mail-qt0-f171.google.com with SMTP id t26so21084399qtg.0
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 13:01:26 -0700 (PDT)
In-Reply-To: <1496259810-3602-1-git-send-email-jon.mason@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/31/2017 12:43 PM, Jon Mason wrote:
> use of_mdio_parse_addr() in place of an OF read of reg and a bounds
> check (which is litterally the exact same thing that
> of_mdio_parse_addr() does)
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
