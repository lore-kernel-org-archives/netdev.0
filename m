From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sun: niu: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 08 Mar 2017 22:06:18 -0800 (PST)
Message-ID: <20170308.220618.1395119959855742727.davem@davemloft.net>
References: <1488646206-8966-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, akpm@linux-foundation.org, vbabka@suse.cz,
        jarod@redhat.com, edumazet@google.com, iamjoonsoo.kim@lge.com,
        fw@strlen.de, stephen@networkplumber.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488646206-8966-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat,  4 Mar 2017 17:50:06 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
