From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/5] net: fix phydev reference leaks
Date: Sun, 27 Nov 2016 23:53:39 -0500 (EST)
Message-ID: <20161127.235339.1732041838368624355.davem@davemloft.net>
References: <1480011691-13278-1-git-send-email-johan@kernel.org>
        <20161127.200238.2048371945400616113.davem@davemloft.net>
        <583B9245.2030809@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johan@kernel.org, f.fainelli@gmail.com, madalin.bucur@nxp.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41148 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753790AbcK1Exn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 23:53:43 -0500
In-Reply-To: <583B9245.2030809@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Sun, 27 Nov 2016 20:11:17 -0600

> David Miller wrote:
>> Series applied, thanks.
> 
> I was really hoping you'd give me the chance to test the patches
> before applying them.

Sorry, if anything is broken I will happily revert if it isn't
fixed promptly.
