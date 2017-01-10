From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [v3] net: qcom/emac: add ethtool support
Date: Tue, 10 Jan 2017 13:28:07 -0500 (EST)
Message-ID: <20170110.132807.68543251128870399.davem@davemloft.net>
References: <1483984992-21236-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, alokc@codeaurora.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49786 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939588AbdAJS2P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:28:15 -0500
In-Reply-To: <1483984992-21236-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Mon,  9 Jan 2017 12:03:12 -0600

> Add support for some ethtool methods: get/set link settings, get/set
> message level, get statistics, get link status, get ring params, get
> pause params, and restart autonegotiation.
> 
> The code to collect the hardware statistics is moved into its own
> function so that it can be used by "get statistics" method.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Applied, thanks.
