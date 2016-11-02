From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: mii: add generic function to support ksetting
 support
Date: Wed, 02 Nov 2016 15:17:22 -0400 (EDT)
Message-ID: <20161102.151722.23282309119443443.davem@davemloft.net>
References: <1478014347-14994-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klassert@mathematik.tu-chemnitz.de, mugunthanvnm@ti.com,
        a@unstable.cc, fw@strlen.de, jarod@redhat.com, fabf@skynet.be,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478014347-14994-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Tue,  1 Nov 2016 16:32:25 +0100

> The old ethtool api (get_setting and set_setting) has generic mii
> functions mii_ethtool_sset and mii_ethtool_gset.
> 
> To support the new ethtool api ({get|set}_link_ksettings), we add
> two generics mii function mii_ethtool_{get|set}_link_ksettings_get.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
