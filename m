From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 3/3] net/macb: Create gem_ethtool_ops for new
 statistics functions
Date: Fri, 16 Jan 2015 00:32:06 -0500 (EST)
Message-ID: <20150116.003206.1048065414555896917.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6D1CAC999F@AcuExch.aculab.com>
	<1421358316-23660-1-git-send-email-xander.huff@ni.com>
	<1421358316-23660-3-git-send-email-xander.huff@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, david.light@aculab.com,
	netdev@vger.kernel.org, jaeden.amero@ni.com, rich.tollerton@ni.com,
	brad.mouring@ni.com, linux-kernel@vger.kernel.org,
	cyrille.pitchen@atmel.com
To: xander.huff@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421358316-23660-3-git-send-email-xander.huff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xander Huff <xander.huff@ni.com>
Date: Thu, 15 Jan 2015 15:45:16 -0600

> 10/100 MACB does not have the same statistics possibilities as GEM. Separate
> macb_ethtool_ops to make a new GEM-specific struct with the new statistics
> functions included.
> 
> Signed-off-by: Xander Huff <xander.huff@ni.com>

Applied.
