From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Wed, 2 Aug 2017 13:39:34 -0500
Message-ID: <3c31277c-93c4-c0a5-cf0d-7270d07c432c@codeaurora.org>
References: <1501623460-3575-2-git-send-email-timur@codeaurora.org>
 <20170802.105453.1408822174555343968.davem@davemloft.net>
 <290fdd25-7e05-57c8-8f89-52bb3bae1e59@codeaurora.org>
 <20170802.113531.1671960264039506111.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57494 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751890AbdHBSjg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 14:39:36 -0400
In-Reply-To: <20170802.113531.1671960264039506111.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2017 01:35 PM, David Miller wrote:
> Again, any serious installation will have a system watchdog enabled
> which will break the pause frame bomb.

Oh well.  I guess I'll have to carry this patch internally.

What about patch #2?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
