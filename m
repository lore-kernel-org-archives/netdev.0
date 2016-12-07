From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v3] net: phy: phy drivers should not set
 SUPPORTED_[Asym_]Pause
Date: Wed, 7 Dec 2016 11:19:13 -0600
Message-ID: <58484491.6020908@codeaurora.org>
References: <1481070443-15118-1-git-send-email-timur@codeaurora.org>
 <2c2aaf1d-05a5-d2bc-d04a-79224a4c6b43@gmail.com>
 <58476ACB.3030206@codeaurora.org>
 <f62595d4-2dd7-9cc3-7537-2ff186dadc8c@gmail.com>
 <58477A03.6000107@codeaurora.org>
 <CAD5ja61A3diBgYwscUSoxJqE1ydmzr+cQ9rR+8uZa0mw-0m_3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>, jon.mason@broadcom.com,
        netdev@vger.kernel.org
To: Niklas Cassel <nks.gnu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:58802 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752548AbcLGRTQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 12:19:16 -0500
In-Reply-To: <CAD5ja61A3diBgYwscUSoxJqE1ydmzr+cQ9rR+8uZa0mw-0m_3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2016 03:13 AM, Niklas Cassel wrote:
> You might want to include drivers/net/phy/dp83848.c in your patch.
> Support for pause frames in that phy was recently added to netdev-next.

Thanks.  I feel bad that I'm reverting your patch just a few days after 
it was applied.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
