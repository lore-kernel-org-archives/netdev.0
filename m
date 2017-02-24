From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vti6: return GRE_KEY for vti6
Date: Fri, 24 Feb 2017 11:38:31 -0500 (EST)
Message-ID: <20170224.113831.1049996329596329532.davem@davemloft.net>
References: <1487946032-5866-1-git-send-email-dforster@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dforster@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751192AbdBXQkS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 11:40:18 -0500
In-Reply-To: <1487946032-5866-1-git-send-email-dforster@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Forster <dforster@brocade.com>
Date: Fri, 24 Feb 2017 14:20:32 +0000

> Align vti6 with vti by returning GRE_KEY flag. This enables iproute2
> to display tunnel keys on "ip -6 tunnel show"
> 
> Signed-off-by: David Forster <dforster@brocade.com>

Applied, thanks.
