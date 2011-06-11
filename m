From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net/m68k: Include <linux/interrupt.h> where
 needed
Date: Sat, 11 Jun 2011 14:58:34 -0700 (PDT)
Message-ID: <20110611.145834.2206118199013627704.davem@davemloft.net>
References: <1307792335-9926-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1307792335-9926-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sat, 11 Jun 2011 13:38:55 +0200

 ...
> Introduced by commit a6b7a407865a ("net: remove interrupt.h inclusion from
> netdevice.h").
> 
> Include <linux/interrupt.h> in the individual drivers to fix the build.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied, thanks!
