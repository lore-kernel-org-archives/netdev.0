From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] irnet: ppp: move IRNET_MINOR to
 include/linux/miscdevice.h
Date: Sat, 17 Dec 2016 11:18:19 -0500 (EST)
Message-ID: <20161217.111819.1550236749603321753.davem@davemloft.net>
References: <20161215104250.16813-1-clabbe.montjoie@gmail.com>
        <20161215104250.16813-3-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, gregkh@linuxfoundation.org, samuel@sortiz.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161215104250.16813-3-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Thu, 15 Dec 2016 11:42:48 +0100

> This patch move the define for IRNET_MINOR to include/linux/miscdevice.h
> It is better that all minor number definitions are in the same place.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Applied.
