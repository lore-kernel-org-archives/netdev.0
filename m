From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] RDS: don't pretend to use cpu notifiers
Date: Tue, 22 Dec 2015 15:23:34 -0500 (EST)
Message-ID: <20151222.152334.1819747411852445574.davem@davemloft.net>
References: <1450558543-3650-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bigeasy@linutronix.de
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450558543-3650-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Sat, 19 Dec 2015 12:55:43 -0800

> From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> 
> It looks like an attempt to use CPU notifier here which was never
> completed. Nobody tried to wire it up completely since 2k9. So I unwind
> this code and get rid of everything not required. Oh look! 19 lines were
> removed while code still does the same thing.
> 
> Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Tested-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Applied to net-next, thanks.
