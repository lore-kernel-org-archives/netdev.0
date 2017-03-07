From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smsc: epic100: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 06 Mar 2017 17:08:21 -0800 (PST)
Message-ID: <20170306.170821.124825281094070130.davem@davemloft.net>
References: <1488235394-11423-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, a@unstable.cc, fw@strlen.de, jarod@redhat.com,
        edumazet@google.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488235394-11423-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Mon, 27 Feb 2017 23:43:14 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
