From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: Have 6161/6123 use EDSA
 tags
Date: Wed, 07 Jun 2017 15:32:11 -0400 (EDT)
Message-ID: <20170607.153211.2215871928299179731.davem@davemloft.net>
References: <1496840779-4260-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cphealy@gmail.com,
        vivien.didelot@savoirfairelinux.com,
        nikita.yoush@cogentembedded.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34688 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbdFGTcN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 15:32:13 -0400
In-Reply-To: <1496840779-4260-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed,  7 Jun 2017 15:06:19 +0200

> The mv88e6161 and mv88e6123 are capable of using EDSA tags when
> passing frames from the host to the switch and back.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied.
