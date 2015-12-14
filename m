From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] drivers/net: fix eisa_driver probe section
 mismatch
Date: Mon, 14 Dec 2015 00:24:41 -0500 (EST)
Message-ID: <20151214.002441.143023648656067275.davem@davemloft.net>
References: <1449941078-15854-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de, perex@perex.cz,
	linux-parisc@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <1449941078-15854-1-git-send-email-fabf@skynet.be>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Sat, 12 Dec 2015 18:24:38 +0100

> Some eisa_driver structures used __init probe functions which generates
> a warning and could crash if function is called after being deleted.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied, thanks.
