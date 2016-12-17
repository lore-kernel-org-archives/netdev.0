From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] irda: irproc.c: Remove unneeded linux/miscdevice.h
 include
Date: Sat, 17 Dec 2016 11:18:09 -0500 (EST)
Message-ID: <20161217.111809.894550361809961712.davem@davemloft.net>
References: <20161215104250.16813-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, gregkh@linuxfoundation.org, samuel@sortiz.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161215104250.16813-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Thu, 15 Dec 2016 11:42:46 +0100

> irproc.c does not use any miscdevice so this patch remove this
> unnecessary inclusion.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Applied.
