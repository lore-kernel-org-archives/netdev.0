From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dec: uli526x: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 02 Jan 2017 19:31:15 -0500 (EST)
Message-ID: <20170102.193115.2247105020827859141.davem@davemloft.net>
References: <1483294266-6222-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, a@unstable.cc, fw@strlen.de, jarod@redhat.com,
        netdev@vger.kernel.org, linux-parisc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483294266-6222-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  1 Jan 2017 19:11:06 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
