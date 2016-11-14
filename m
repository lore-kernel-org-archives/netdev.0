From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: alx: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 14 Nov 2016 13:38:05 -0500 (EST)
Message-ID: <20161114.133805.1300179159231705602.davem@davemloft.net>
References: <1478903437-9049-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478903437-9049-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Fri, 11 Nov 2016 23:30:37 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
