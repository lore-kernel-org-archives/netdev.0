From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: 3c59x: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 02 Nov 2016 15:17:27 -0400 (EDT)
Message-ID: <20161102.151727.60893707135192312.davem@davemloft.net>
References: <1478014347-14994-1-git-send-email-tremyfr@gmail.com>
        <1478014347-14994-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klassert@mathematik.tu-chemnitz.de, mugunthanvnm@ti.com,
        a@unstable.cc, fw@strlen.de, jarod@redhat.com, fabf@skynet.be,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478014347-14994-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Tue,  1 Nov 2016 16:32:26 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
