From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neighbour: Convert NEIGH_PRINTK to neigh_dbg
Date: Tue, 16 Apr 2013 16:42:15 -0400 (EDT)
Message-ID: <20130416.164215.1481542365151784733.davem@davemloft.net>
References: <6d196be46acd99bd65d0f0d5abb842b8b0bf0d04.1366074978.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6d196be46acd99bd65d0f0d5abb842b8b0bf0d04.1366074978.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 15 Apr 2013 18:17:19 -0700

> Update debugging messages to a more current style.
> 
> Emit these debugging messages at KERN_DEBUG instead
> of KERN_DEFAULT.
> 
> Add and use neigh_dbg(level, fmt, ...) macro
> Add dynamic_debug capability via pr_debug
> Convert embedded function names to "%s: ", __func__
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
