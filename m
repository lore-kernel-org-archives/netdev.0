From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] net: qcom/emac: configure the external phy to allow
 pause frames
Date: Tue, 1 Nov 2016 13:34:46 -0500
Message-ID: <5818E046.30907@codeaurora.org>
References: <1478025055-13167-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:39302 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753805AbcKASes (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 14:34:48 -0400
In-Reply-To: <1478025055-13167-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timur Tabi wrote:
> Pause frames are used to enable flow control.  A MAC can send and
> receive pause frames in order to throttle traffic.  However, the PHY
> must be configured to allow those frames to pass through.
>
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Ugh, I forgot to include an introductory post.  Coming right up.


-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
