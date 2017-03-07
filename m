From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: realtek: 8139too: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 06 Mar 2017 17:07:20 -0800 (PST)
Message-ID: <20170306.170720.1522772631308365727.davem@davemloft.net>
References: <1487805248-18450-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hau@realtek.com, jarod@redhat.com, stephen@networkplumber.org,
        edumazet@google.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487805248-18450-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu, 23 Feb 2017 00:14:08 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
