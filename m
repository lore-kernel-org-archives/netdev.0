From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] net: qcom/emac: configure the external phy to allow
 pause frames
Date: Tue, 1 Nov 2016 11:33:53 -0700
Message-ID: <e6400726-e384-e649-5d17-1013c4687c4a@gmail.com>
References: <1478025055-13167-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33727 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752728AbcKASd5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 14:33:57 -0400
Received: by mail-pf0-f176.google.com with SMTP id d2so24304301pfd.0
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 11:33:56 -0700 (PDT)
In-Reply-To: <1478025055-13167-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2016 11:30 AM, Timur Tabi wrote:
> Pause frames are used to enable flow control.  A MAC can send and
> receive pause frames in order to throttle traffic.  However, the PHY
> must be configured to allow those frames to pass through.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
