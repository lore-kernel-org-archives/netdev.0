From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: renesas: ravb: use new api
 ethtool_{get|set}_link_ksettings
Date: Sat, 20 Aug 2016 22:27:53 -0700 (PDT)
Message-ID: <20160820.222753.1870314112887146628.davem@davemloft.net>
References: <1471647139-1867-1-git-send-email-tremyfr@gmail.com>
        <1471647139-1867-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com,
        kazuya.mizuguchi.ks@renesas.com, ykaneko0929@gmail.com,
        horms+renesas@verge.net.au, masaru.nagai.vx@renesas.com,
        geert+renesas@glider.be, niklas.soderlund+renesas@ragnatech.se,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471647139-1867-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 20 Aug 2016 00:52:19 +0200

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
