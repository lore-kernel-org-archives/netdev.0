From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: amd8111e: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 09 Nov 2016 13:25:37 -0500 (EST)
Message-ID: <20161109.132537.50985902487458732.davem@davemloft.net>
References: <1478373423-15837-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, geert@linux-m68k.org, javier@osg.samsung.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478373423-15837-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat,  5 Nov 2016 20:17:03 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
