From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vsock: vmci: Remove unneeded linux/miscdevice.h include
Date: Tue, 19 Sep 2017 13:52:24 -0700 (PDT)
Message-ID: <20170919.135224.1429860329333142738.davem@davemloft.net>
References: <20170918181855.32211-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170918181855.32211-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Mon, 18 Sep 2017 20:18:55 +0200

> net/vmw_vsock/vmci_transport.c does not use any miscdevice so this patch
> remove this unnecessary inclusion.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Applied, thank you.
