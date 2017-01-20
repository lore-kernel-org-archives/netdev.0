From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] net: qcom/emac: claim the irq only when the device is
 opened
Date: Fri, 20 Jan 2017 11:22:50 -0600
Message-ID: <35780cd0-e133-b47e-c841-b78f2bbff888@codeaurora.org>
References: <1484775745-14050-1-git-send-email-timur@codeaurora.org>
 <20170120.121901.1924570978922182141.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45134 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752605AbdATRad (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:30:33 -0500
In-Reply-To: <20170120.121901.1924570978922182141.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2017 11:19 AM, David Miller wrote:

> If you don't tell me what tree this is against in your Subject line,
> I have to guess.
>
> I don't like guessing.

Sorry, this is for net-next.  I will specify the target tree in all future 
patches.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
