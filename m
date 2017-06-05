From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Fixes for mv88e6161
Date: Sun, 04 Jun 2017 21:35:05 -0400 (EDT)
Message-ID: <20170604.213505.1633234228737937171.davem@davemloft.net>
References: <1496438566-30612-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        nikita.yoush@cogentembedded.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54180 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751213AbdFEBfH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 21:35:07 -0400
In-Reply-To: <1496438566-30612-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri,  2 Jun 2017 23:22:44 +0200

> Testing a board with an mv88e6161 turned up two issues. The PHYs were
> not found, because the wrong method to access them was used. The
> statistics did not work, because the wrong snapshot method was used

Series applied, thanks Andrew.
