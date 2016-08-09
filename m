From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: dsa: b53: constify b53_io_ops structures
Date: Tue, 09 Aug 2016 15:10:02 -0700 (PDT)
Message-ID: <20160809.151002.825441860378434543.davem@davemloft.net>
References: <1470762585-2670-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470762585-2670-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Tue,  9 Aug 2016 19:09:45 +0200

> The b53_io_ops structures are never modified, so declare them as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
> v2: Refer to the right structure in the commit message

Applied to net-next, thanks.
