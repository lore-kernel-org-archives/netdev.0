From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V2 2/3] net: phy: broadcom: drop duplicated define for
 RGMII SKEW delay
Date: Wed, 25 Jan 2017 12:34:31 -0800
Message-ID: <027ef232-d385-43f3-b67c-42e4080bb3c2@gmail.com>
References: <20170125200027.14387-1-zajec5@gmail.com>
 <20170125200027.14387-3-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Xo Wang <xow@google.com>, Joel Stanley <joel@jms.id.au>,
        Jon Mason <jon.mason@broadcom.com>,
        Jaedon Shin <jaedon.shin@gmail.com>, netdev@vger.kernel.org,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35322 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751324AbdAYUee (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 15:34:34 -0500
Received: by mail-pf0-f193.google.com with SMTP id f144so15037571pfa.2
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 12:34:34 -0800 (PST)
In-Reply-To: <20170125200027.14387-3-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2017 12:00 PM, Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> We had two defines for the same bit (both were used with the
> MII_BCM54XX_AUXCTL_SHDWSEL_MISC register).
> 
> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
