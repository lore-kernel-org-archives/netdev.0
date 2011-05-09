From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] tulip: Convert printks to netdev_<level>
Date: Mon, 09 May 2011 12:51:54 -0700 (PDT)
Message-ID: <20110509.125154.35047036.davem@davemloft.net>
References: <cover.1304970062.git.joe@perches.com>
	<c9b94faed52877c10be832da384d9a327c36193a.1304970062.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c9b94faed52877c10be832da384d9a327c36193a.1304970062.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon,  9 May 2011 12:45:21 -0700

> Use the current more descriptive logging styles.
> 
> Add pr_fmt and remove PFX where appropriate.
> Use netif_<level>, netdev_<level>
> Indent a few blocks in xircom_cb where appropriate.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
