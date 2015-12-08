From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/3] sh_eth: factor out common code from MDIO bitbang
 methods
Date: Tue, 8 Dec 2015 09:42:30 +0900
Message-ID: <20151208004230.GI10799@verge.net.au>
References: <1582774.FcjyuztLtc@wasted.cogentembedded.com>
 <2708108.aPmlclaWv5@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2708108.aPmlclaWv5@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 08, 2015 at 12:40:57AM +0300, Sergei Shtylyov wrote:
> sh_mm[cd]_ctrl()  and sh_set_mdio() all look mostly the same -- factor out
> their common code and put it into sh_mdio_ctrl().
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Acked-by: Simon Horman <horms+renesas@verge.net.au>

