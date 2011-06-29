From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Wed, 29 Jun 2011 02:56:17 -0700 (PDT)
Message-ID: <20110629.025617.399441642697796814.davem@davemloft.net>
References: <20110623152535.e9ec4ad2.sfr@canb.auug.org.au>
	<20110627153522.8884b125.sfr@canb.auug.org.au>
	<20110629160133.372e53ed.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, adobriyan@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110629160133.372e53ed.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 29 Jun 2011 16:01:33 +1000

> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 29 Jun 2011 15:52:00 +1000
> Subject: [PATCH] net: include io.h in for iounmap etc
> 
> fixes these build errors:
 ...
> Caused by commit b7f080cfe223 ("net: remove mm.h inclusion from
> netdevice.h").
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Applied.
