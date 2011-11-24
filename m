From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: linux-next: manual merge of the arm-soc tree with Linus' tree
Date: Thu, 24 Nov 2011 15:55:03 +0000
Message-ID: <201111241555.03715.arnd@arndb.de>
References: <20111124115805.d2b5cdc699b9d6ed300b9c09@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Jean-Christophe PLAGNIOL-VILLARD" <plagnioj@jcrosoft.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jamie Iles <jamie.iles@mathembedded.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20111124115805.d2b5cdc699b9d6ed300b9c09@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 24 November 2011, Stephen Rothwell wrote:
> Today's linux-next merge of the arm-soc tree got a conflict in
> drivers/net/ethernet/cadence/Kconfig between commit eccab1ec87d0
> ("net/cadence: enable by default NET_ATMEL") from Linus' tree and commit
> f75ba50bdc2b ("macb: initial support for Cadence GEM") from the arm-soc
> tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.

Yes, looks good.

Thanks,

	Arnd
