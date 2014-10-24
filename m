From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] natsemi/macsonic: Remove superfluous interrupt
 disable/restore
Date: Fri, 24 Oct 2014 00:43:45 -0400 (EDT)
Message-ID: <20141024.004345.461366425082981012.davem@davemloft.net>
References: <1413914037-23693-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413914037-23693-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 21 Oct 2014 19:53:57 +0200

> As of commit e4dc601bf99ccd1c ("m68k: Disable/restore interrupts in
> hwreg_present()/hwreg_write()"), this is no longer needed.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied.
