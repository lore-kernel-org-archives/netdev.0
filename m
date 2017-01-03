From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dlink: sundance: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 02 Jan 2017 19:31:31 -0500 (EST)
Message-ID: <20170102.193131.847573568223493531.davem@davemloft.net>
References: <1483300332-22834-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kda@linux-powerpc.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483300332-22834-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  1 Jan 2017 20:52:12 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
