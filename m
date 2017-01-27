From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: micrel: KSZ8795 do not set
 SUPPORTED_[Asym_]Pause
Date: Fri, 27 Jan 2017 12:51:42 -0800
Message-ID: <2470d396-2ebf-e736-d482-231015969154@gmail.com>
References: <20170127203903.19171-1-sean.nyekjaer@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Sean Nyekjaer <sean.nyekjaer@prevas.dk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34889 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750887AbdA0UxV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 15:53:21 -0500
Received: by mail-pf0-f196.google.com with SMTP id f144so19223950pfa.2
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 12:51:44 -0800 (PST)
In-Reply-To: <20170127203903.19171-1-sean.nyekjaer@prevas.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/2017 12:39 PM, Sean Nyekjaer wrote:
> As pr commit "net: phy: phy drivers should not set SUPPORTED_[Asym_]Pause"
> this phy driver should not set these feature bits.
> 
> Signed-off-by: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
> Fixes: 9d162ed69f51 ("net: phy: micrel: add support for KSZ8795")

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
