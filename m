From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] net: qcom/emac: move phy init code to separate files
Date: Thu, 24 Nov 2016 10:39:42 -0600
Message-ID: <583717CE.9070704@codeaurora.org>
References: <1479769102-27909-1-git-send-email-timur@codeaurora.org>
 <1479769102-27909-2-git-send-email-timur@codeaurora.org>
 <20161124.113220.1130207009395086230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alokc@codeaurora.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33812 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754550AbcKXQjo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 11:39:44 -0500
In-Reply-To: <20161124.113220.1130207009395086230.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Please do not place empty blank lines at the end of files.
>
> GIT even warns about this.

I need to rework this patchset anyway, and it won't be ready in time for 
4.10.  I will definitely fix this problem.  Thanks.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
