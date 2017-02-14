From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: fs_enet: Simplify code
Date: Mon, 13 Feb 2017 22:12:39 -0500 (EST)
Message-ID: <20170213.221239.2041391041651777898.davem@davemloft.net>
References: <20170210201719.16636-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
        linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170210201719.16636-1-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Fri, 10 Feb 2017 21:17:19 +0100

> There is no need to use an intermediate variable to handle an error code
> in this case.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Applied.
