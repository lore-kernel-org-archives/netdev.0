From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: korina: use new api
 ethtool_{get|set}_link_ksettings
Date: Tue, 17 Jan 2017 11:46:06 -0500 (EST)
Message-ID: <20170117.114606.893607814196784410.davem@davemloft.net>
References: <1484393599-1547-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, a@unstable.cc, fw@strlen.de, jarod@redhat.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484393599-1547-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 14 Jan 2017 12:33:19 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
