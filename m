From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: adaptec: starfire: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 09 Nov 2016 13:25:26 -0500 (EST)
Message-ID: <20161109.132526.1327662795576391650.davem@davemloft.net>
References: <1478351139-1720-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ionut@badula.org, mugunthanvnm@ti.com, a@unstable.cc, fw@strlen.de,
        jarod@redhat.com, javier@osg.samsung.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478351139-1720-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat,  5 Nov 2016 14:05:39 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
