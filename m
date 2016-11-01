From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] net: qcom/emac: enable flow control if requested
Date: Tue, 1 Nov 2016 11:34:56 -0700
Message-ID: <f38701ad-001e-1032-dbc4-90fbe39cd384@gmail.com>
References: <1478025055-13167-1-git-send-email-timur@codeaurora.org>
 <1478025055-13167-2-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32921 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750871AbcKASe7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 14:34:59 -0400
Received: by mail-pf0-f196.google.com with SMTP id a136so8909244pfa.0
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 11:34:59 -0700 (PDT)
In-Reply-To: <1478025055-13167-2-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2016 11:30 AM, Timur Tabi wrote:
> If the PHY has been configured to allow pause frames, then the MAC
> should be configured to generate and/or accept those frames.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
