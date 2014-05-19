From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: Convert return 0 to return rc
Date: Sun, 18 May 2014 20:51:35 -0400 (EDT)
Message-ID: <20140518.205135.2035618521487962929.davem@davemloft.net>
References: <1400223103.30884.5.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, dmitry@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400223103.30884.5.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 15 May 2014 23:51:43 -0700

> These "return 0;" uses seem wrong as there are
> rc variables where error return values are set
> but unused.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
