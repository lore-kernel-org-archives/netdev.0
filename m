From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] yam: use memdup_user
Date: Mon, 08 May 2017 15:02:27 -0400 (EDT)
Message-ID: <20170508.150227.1491065214426888698.davem@davemloft.net>
References: <df8091d4c64a0d5a7ab0a5989f34552a5eebd15e.1493778999.git.geliangtang@gmail.com>
        <bd8ca4a87fc128e5260c13960423f025e1b42c5c.1493783298.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpr@f6fbb.org, linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: geliangtang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35166 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755234AbdEHTC3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 15:02:29 -0400
In-Reply-To: <bd8ca4a87fc128e5260c13960423f025e1b42c5c.1493783298.git.geliangtang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geliang Tang <geliangtang@gmail.com>
Date: Sat,  6 May 2017 23:42:22 +0800

> Use memdup_user() helper instead of open-coding to simplify the code.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Applied.
