From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: wan: Remove unused stats member from struct
 frad_local
Date: Fri, 27 Jan 2017 11:32:56 -0500 (EST)
Message-ID: <20170127.113256.1920396902479658763.davem@davemloft.net>
References: <20170127142632.29332-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43808 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933292AbdA0R0p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 12:26:45 -0500
In-Reply-To: <20170127142632.29332-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri, 27 Jan 2017 15:26:32 +0100

> The stats member of struct frad_locl is used neither by the dlci nor the
> sdla driver, so it might as well be removed.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
