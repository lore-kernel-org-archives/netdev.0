From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smsc: smc91c92_cs: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 06 Mar 2017 17:08:27 -0800 (PST)
Message-ID: <20170306.170827.1478752194388095944.davem@davemloft.net>
References: <1488580775-27415-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, jarod@redhat.com,
        felipe.balbi@linux.intel.com, edumazet@google.com, fw@strlen.de,
        tklauser@distanz.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488580775-27415-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Fri,  3 Mar 2017 23:39:35 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
