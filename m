From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh_eth: fix endian check for architecture
 independent
Date: Sun, 01 Apr 2012 23:22:34 -0400 (EDT)
Message-ID: <20120401.232234.686879895812528970.davem@davemloft.net>
References: <4F754558.1070001@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4F754558.1070001@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Date: Fri, 30 Mar 2012 14:32:08 +0900

> SuperH has the "CONFIG_CPU_LITTLE_ENDIAN" and the "__LITTLE_ENDIAN__".
> But, other architecture doesn't have them. So, this patch fixes it.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
