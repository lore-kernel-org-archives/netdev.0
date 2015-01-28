From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1] net: netcp: remove unused kconfig option
 and code
Date: Tue, 27 Jan 2015 17:19:31 -0800 (PST)
Message-ID: <20150127.171931.1483421801202546665.davem@davemloft.net>
References: <1422370194-2828-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: m-karicheri2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422370194-2828-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Murali Karicheri <m-karicheri2@ti.com>
Date: Tue, 27 Jan 2015 09:49:54 -0500

> Currently CPTS is built into the netcp driver even though there is no
> call out to the CPTS driver. This patch removes the dependency in Kconfig
> and remove cpts.o from the Makefile for NetCP.
> 
> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>

Applied, thank you.
