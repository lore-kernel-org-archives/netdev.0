From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v5 2/2] net: phy: at803x: Change error to EINVAL for
 invalid MAC
Date: Tue, 10 Oct 2017 10:43:56 -0700
Message-ID: <075ae93c-f1b8-2fae-4741-56327f51db98@gmail.com>
References: <20171010174256.21930-1-dmurphy@ti.com>
 <20171010174256.21930-2-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Woojung.Huh@microchip.com, afd@ti.com
To: Dan Murphy <dmurphy@ti.com>, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:54597 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756156AbdJJRn7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 13:43:59 -0400
Received: by mail-qt0-f175.google.com with SMTP id z19so8174420qtg.11
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 10:43:59 -0700 (PDT)
In-Reply-To: <20171010174256.21930-2-dmurphy@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2017 10:42 AM, Dan Murphy wrote:
> Change the return error code to EINVAL if the MAC
> address is not valid in the set_wol function.
> 
> Signed-off-by: Dan Murphy <dmurphy@ti.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
