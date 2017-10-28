From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phylink: Use common error handling code in
 phylink_create()
Date: Sat, 28 Oct 2017 14:08:49 -0700
Message-ID: <60594e3d-c8ec-16a0-1fec-3fc854334321@gmail.com>
References: <f52bdf2b-d45f-7db4-b533-d96dd3b4f6bf@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>,
        Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:50603 "EHLO
        mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751447AbdJ1VIx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 17:08:53 -0400
In-Reply-To: <f52bdf2b-d45f-7db4-b533-d96dd3b4f6bf@users.sourceforge.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/28/2017 01:00 PM, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 28 Oct 2017 21:48:31 +0200
> 
> * Add a jump target so that a bit of exception handling can be better
>   reused at the end of this function.
> 
> * Adjust three condition checks.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
