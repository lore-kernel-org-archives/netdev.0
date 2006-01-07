From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/ipv6/: small cleanups
Date: Sat, 07 Jan 2006 13:24:42 -0800 (PST)
Message-ID: <20060107.132442.80466568.davem@davemloft.net>
References: <20060107181723.GP3774@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030588AbWAGVYz@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20060107181723.GP3774@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sat, 7 Jan 2006 19:17:23 +0100

> This patch contains the following cleanups:
> - addrconf.c: make addrconf_dad_stop() static
> - inet6_connection_sock.c should #include <net/inet6_connection_sock.h>
>   for getting the prototypes of it's global functions
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Also applied, thanks.
