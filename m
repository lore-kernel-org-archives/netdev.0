From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] drivers: net: phy: Correct duplicate MDIO_XGENE entry
Date: Thu, 6 Oct 2016 12:48:59 -0700
Message-ID: <c0dfb33f-3477-1834-f134-b2ea8d71fd42@gmail.com>
References: <1475778171-10905-1-git-send-email-labbott@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
To: Laura Abbott <labbott@redhat.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34125 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933299AbcJFTtD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 15:49:03 -0400
In-Reply-To: <1475778171-10905-1-git-send-email-labbott@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/06/2016 11:22 AM, Laura Abbott wrote:
> An extra entry for MDIO_XGENE got added during merging.
> Delete it.
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Laura Abbott <labbott@redhat.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
