From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gigaset: fix build failure
Date: Wed, 17 Mar 2010 14:22:24 -0700 (PDT)
Message-ID: <20100317.142224.193700644.davem@davemloft.net>
References: <20100317211231.569B140118@xenon.ts.pxnet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, hjlipp@web.de,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@kernel.org
To: tilman@imap.cc
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100317211231.569B140118@xenon.ts.pxnet.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>
Date: Wed, 17 Mar 2010 18:37:05 +0100

> Update the dummy LL interface to the LL interface change
> introduced by commit daab433c03c15fd642c71c94eb51bdd3f32602c8.
> This fixes the build failure occurring after that commit when
> enabling ISDN_DRV_GIGASET but neither ISDN_I4L nor ISDN_CAPI.
> 
> Impact: bugfix
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Applied, thanks.
