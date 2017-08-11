From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 1/2] wan: dscc4: add checks for dma mapping
 errors
Date: Fri, 11 Aug 2017 14:42:47 -0700 (PDT)
Message-ID: <20170811.144247.1138775470621031230.davem@davemloft.net>
References: <20170808232147.GA27445@electric-eye.fr.zoreil.com>
        <1502405721-27738-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502405721-27738-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Fri, 11 Aug 2017 01:55:20 +0300

> The driver does not check if mapping dma memory succeed.
> The patch adds the checks and failure handling.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied.
