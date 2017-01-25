From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: Mop up remaining NET_DSA_HWMON references
Date: Wed, 25 Jan 2017 14:45:29 -0500 (EST)
Message-ID: <20170125.144529.586555336340775169.davem@davemloft.net>
References: <1485353057-4612-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, valentinrothberg@gmail.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33452 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751807AbdAYTpb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 14:45:31 -0500
In-Reply-To: <1485353057-4612-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 25 Jan 2017 15:04:17 +0100

> Previous patches have moved the temperature sensor code into the
> Marvell PHYs. A few now dead references to NET_DSA_HWMON were left
> behind. Go reap them.
> 
> Reported-by: Valentin Rothberg <valentinrothberg@gmail.com>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied to... net-next :-)
