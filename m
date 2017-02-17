From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: nvidia: forcedeth: use new api
 ethtool_{get|set}_link_ksettings
Date: Fri, 17 Feb 2017 11:05:49 -0500 (EST)
Message-ID: <20170217.110549.298566325011357008.davem@davemloft.net>
References: <1487111792-26192-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amitoj1606@gmail.com, jarod@redhat.com, stephen@networkplumber.org,
        edumazet@google.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487111792-26192-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Tue, 14 Feb 2017 23:36:32 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied to net-next, thanks Philippe.
