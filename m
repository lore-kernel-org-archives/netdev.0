From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] bna: remove useless calls to memset().
Date: Sun, 02 Dec 2012 20:33:09 -0500 (EST)
Message-ID: <20121202.203309.1858145449914043352.davem@davemloft.net>
References: <1354416022-20189-1-git-send-email-tipecaml@gmail.com>
	<1354416022-20189-2-git-send-email-tipecaml@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	rmody@brocade.com, netdev@vger.kernel.org
To: tipecaml@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354416022-20189-2-git-send-email-tipecaml@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyril Roelandt <tipecaml@gmail.com>
Date: Sun,  2 Dec 2012 03:40:17 +0100

> These calls are followed by calls to memcpy() on the same memory area, so they
> can safely be removed.
> 
> Signed-off-by: Cyril Roelandt <tipecaml@gmail.com>

Applied, thanks.
