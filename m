From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qlcnic: Deletion of unnecessary memset
Date: Wed, 15 Jul 2015 17:20:46 -0700 (PDT)
Message-ID: <20150715.172046.1479959081115644674.davem@davemloft.net>
References: <fad6a2ad1e78d8e2624903524548f8d806bf1ef0.1436816968.git.christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shahed.shaikh@qlogic.com, Dept-GELinuxNICDev@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fad6a2ad1e78d8e2624903524548f8d806bf1ef0.1436816968.git.christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Mon, 13 Jul 2015 21:51:38 +0200

> There is no need to memset memory allocated with vzalloc.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Applied and queued up for -stable, thanks.
