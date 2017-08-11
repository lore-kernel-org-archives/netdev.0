From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] phylink: Fix an uninitialized variable bug
Date: Fri, 11 Aug 2017 13:58:25 -0700 (PDT)
Message-ID: <20170811.135825.69794999824395524.davem@davemloft.net>
References: <20170809213550.rga6tlohagu2pm2y@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, rmk+kernel@arm.linux.org.uk, f.fainelli@gmail.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59618 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753793AbdHKU6Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 16:58:25 -0400
In-Reply-To: <20170809213550.rga6tlohagu2pm2y@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 10 Aug 2017 00:35:50 +0300

> "ret" isn't necessarily initialized here.
> 
> Fixes: 9525ae83959b ("phylink: add phylink infrastructure")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
