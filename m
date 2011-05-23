From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: filter: move forward declarations to avoid
 compile warnings
Date: Sun, 22 May 2011 21:01:59 -0400 (EDT)
Message-ID: <20110522.210159.2028885878337277330.davem@davemloft.net>
References: <20110522170811.GA2758@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: heiko.carstens@de.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110522170811.GA2758@osiris.boeblingen.de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Sun, 22 May 2011 19:08:11 +0200

> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Get rid of this compile warning:
> 
> In file included from arch/s390/kernel/compat_linux.c:37:0:
> include/linux/filter.h:139:23: warning: 'struct sk_buff' declared inside parameter list
> 
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Applied.
