From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Wed, 28 Jul 2010 22:21:05 -0700 (PDT)
Message-ID: <20100728.222105.26961969.davem@davemloft.net>
References: <20100729141306.f27fad7a.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, dmitry@broadcom.com,
	eilong@broadcom.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100729141306.f27fad7a.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 29 Jul 2010 14:13:06 +1000

> net: bnx2x_cmn.c needs net/ip6_checksum.h for csum_ipv6_magic
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Applied, thanks Stephen.
