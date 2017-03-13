From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tundra: tsi108: use new api
 ethtool_{get|set}_link_ksettings
Date: Sun, 12 Mar 2017 19:28:27 -0700 (PDT)
Message-ID: <20170312.192827.524077671473392254.davem@davemloft.net>
References: <1488839169-3813-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, jarod@redhat.com,
        julia.lawall@lip6.fr, edumazet@google.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488839169-3813-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Mon,  6 Mar 2017 23:26:09 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
