From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rps: fix uninitialized symbol warning
Date: Tue, 13 Jun 2017 11:30:40 -0400 (EDT)
Message-ID: <20170613.113040.2297985433236578499.davem@davemloft.net>
References: <1497353095-8712-1-git-send-email-ashwanth@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ashwanth@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41858 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752326AbdFMPam (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 11:30:42 -0400
In-Reply-To: <1497353095-8712-1-git-send-email-ashwanth@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ashwanth Goli <ashwanth@codeaurora.org>
Date: Tue, 13 Jun 2017 16:54:55 +0530

> This patch fixes uninitialized symbol warning that
> got introduced by the following commit
> 773fc8f6e8d6 ("net: rps: send out pending IPI's on CPU hotplug")
> 
> Signed-off-by: Ashwanth Goli <ashwanth@codeaurora.org>

Applied.
