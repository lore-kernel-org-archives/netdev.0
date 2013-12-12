From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eth: cpsw: 64-bit phys_addr_t and sparse cleanup
Date: Wed, 11 Dec 2013 19:54:31 -0500 (EST)
Message-ID: <20131211.195431.261557837240498212.davem@davemloft.net>
References: <1386806287-6564-1-git-send-email-olof@lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org
To: olof@lixom.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386806287-6564-1-git-send-email-olof@lixom.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olof Johansson <olof@lixom.net>
Date: Wed, 11 Dec 2013 15:58:07 -0800

> Minor fix for printk format of a phys_addr_t, and the switch of two local
> functions to static since they're not used outside of the file.
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

Applied.
