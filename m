From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net,bonding: fix bond_options.c direct rwlock.h include
Date: Fri, 14 Feb 2014 16:21:01 -0500 (EST)
Message-ID: <20140214.162101.359269415805856434.davem@davemloft.net>
References: <1392362464.5579.41.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bitbucket@online.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392362464.5579.41.camel@marge.simpson.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mike Galbraith <bitbucket@online.de>
Date: Fri, 14 Feb 2014 08:21:04 +0100

> drivers/net/bonding/bond_options.c includes rwlock.h directly,
> which is a nono, and which also breaks RT kernel build.
> 
> Signed-off-by: Mike Galbraith <bitbucket@online.de>

Applied, thank you.
