From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1c: Add support for Atheros AR8152 and AR8152
Date: Tue, 16 Feb 2010 15:16:56 -0800 (PST)
Message-ID: <20100216.151656.123276889.davem@davemloft.net>
References: <1265934812-14157-1-git-send-email-lrodriguez@atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	espy@canonical.com, ken.wu@atheros.com,
	graham.richards@atheros.com, scott.tan@atheros.com,
	mcgrof@gmail.com, chris.snook@gmail.com
To: lrodriguez@atheros.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1265934812-14157-1-git-send-email-lrodriguez@atheros.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Date: Thu, 11 Feb 2010 19:33:32 -0500

> AR8151 is a Gigabit Ethernet device. AR8152 devices are
> Fast Ethernet devices, there are two revisions, a 1.0
> and a 2.0 revision.
> 
> This has been tested against these devices:
> 
> Driver	Model-name	vendor:device	Type
> atl1c 	AR8131		1969:1063	Gigabit Ethernet
> atl1c	AR8132		1969:1062	Fast Ethernet
> atl1c	AR8151(v1.0)	1969:1073	Gigabit Ethernet
> atl1c	AR8152(v1.1)	1969:2060	Fast Ethernet
> 
> This device has no hardware available yet so it goes untested,
> but it should work:
> 
> atl1c	AR8152(v2.0)	1969:2062	Fast Ethernet
> 
> Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>

Applied to net-next-2.6, thanks.
