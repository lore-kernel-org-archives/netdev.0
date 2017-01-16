From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: sr: add missing Kbuild export for
 header files
Date: Mon, 16 Jan 2017 14:47:34 -0500 (EST)
Message-ID: <20170116.144734.1527924719436158876.davem@davemloft.net>
References: <1484490376-3467-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47538 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750970AbdAPTrj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 14:47:39 -0500
In-Reply-To: <1484490376-3467-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Sun, 15 Jan 2017 15:26:16 +0100

> Add missing IPv6-SR header files in include/uapi/linux/Kbuild.
> 
> Also, prevent seg6_lwt_headroom() from being exported and add
> missing linux/types.h include.
> 
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

Applied, thanks.
