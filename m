From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: Re: [PATCH] macb: Fix speed setting
Date: Thu, 21 Feb 2008 17:39:23 +0100
Message-ID: <20080221173923.1301d0c9@dhcp-252-066.norway.atmel.com>
References: <20080221.225054.61509660.anemo@mba.ocn.ne.jp>
	<20080221151246.6f2044b9@dhcp-252-066.norway.atmel.com>
	<20080222.000731.18312290.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934303AbYBUQjz@vger.kernel.org>
In-Reply-To: <20080222.000731.18312290.anemo@mba.ocn.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Feb 2008 00:07:31 +0900 (JST)
Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:

> > I'm willing to take your word for it, but some documentation would be
> > really nice...  
> 
> Well, simple grepping drivers/net/phy enlighten us ;)

Yeah, the patch certainly looks correct as far as I can tell.

> Anyway, this patch fixes problem with 10Mbps on AT91SAM9260 board.

Thanks. I'll pass it on.

Haavard
