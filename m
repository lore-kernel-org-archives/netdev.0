From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: remove unused in6_addr struct
Date: Mon, 21 Mar 2016 14:13:27 -0400 (EDT)
Message-ID: <20160321.141327.1149650430866826875.davem@davemloft.net>
References: <1458581848-844-1-git-send-email-luisbg@osg.samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	javier@osg.samsung.com
To: luisbg@osg.samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458581848-844-1-git-send-email-luisbg@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Luis de Bethencourt <luisbg@osg.samsung.com>
Date: Mon, 21 Mar 2016 17:37:28 +0000

> struct in6_addr isn't used anymore in inet6_connection_sock.h, removing
> the forward declaration.
> 
> Fixes: 1b33bc3e9e90 ("ipv6: remove obsolete inet6 functions")
> Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>

Applied, thank you.
