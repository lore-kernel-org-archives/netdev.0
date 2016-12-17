From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] irda: irnet: Move linux/miscdevice.h include
Date: Sat, 17 Dec 2016 11:18:14 -0500 (EST)
Message-ID: <20161217.111814.575225544081662003.davem@davemloft.net>
References: <20161215104250.16813-1-clabbe.montjoie@gmail.com>
        <20161215104250.16813-2-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, gregkh@linuxfoundation.org, samuel@sortiz.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161215104250.16813-2-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Thu, 15 Dec 2016 11:42:47 +0100

> The only use of miscdevice is irda_ppp so no need to include
> linux/miscdevice.h for all irda files.
> This patch move the linux/miscdevice.h include to irnet_ppp.h
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Applied.
