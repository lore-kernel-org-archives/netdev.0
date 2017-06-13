From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netconsole: Remove duplicate "netconsole: " logging
 prefix
Date: Tue, 13 Jun 2017 13:01:13 -0400 (EDT)
Message-ID: <20170613.130113.821856309419998730.davem@davemloft.net>
References: <a61deabca48ccbbfb1b0d077881d114ad0c5bc75.1497310740.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a61deabca48ccbbfb1b0d077881d114ad0c5bc75.1497310740.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 12 Jun 2017 16:39:51 -0700

> It's already added by pr_fmt so remove the explicit use.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
