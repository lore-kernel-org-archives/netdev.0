From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] pcnet32: factor out pcnet32_clr_suspend()
Date: Tue, 14 Feb 2017 14:28:29 -0500 (EST)
Message-ID: <20170214.142829.2209542102219622424.davem@davemloft.net>
References: <1487025947-28867-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pcnet32@frontier.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41434 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750831AbdBNT2d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 14:28:33 -0500
In-Reply-To: <1487025947-28867-1-git-send-email-linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ondrej Zary <linux@rainbow-software.org>
Date: Mon, 13 Feb 2017 23:45:46 +0100

> Move the code to clear SUSPEND flag to a separate function to simplify
> code.
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Applied to net-next.
