From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: Use kmemdup rather than duplicating its
 implementation
Date: Mon, 21 Nov 2011 15:04:09 -0500 (EST)
Message-ID: <20111121.150409.1335637946878560451.davem@davemloft.net>
References: <1321571135.1624.313.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thomas@m3y3r.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321571135.1624.313.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Meyer <thomas@m3y3r.de>
Date: Fri, 18 Nov 2011 00:05:35 +0100

> The semantic patch that makes this change is available
> in scripts/coccinelle/api/memdup.cocci.
> 
> Signed-off-by: Thomas Meyer <thomas@m3y3r.de>

Applied, with subject line prefix fixed to be "gianfar: "
