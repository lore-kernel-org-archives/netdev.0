From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] ipip: dereferencing an ERR_PTR in
 ip_tunnel_init_net()
Date: Tue, 20 Aug 2013 15:08:42 -0700 (PDT)
Message-ID: <20130820.150842.1107029275114571386.davem@davemloft.net>
References: <20130819070510.GE28591@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130819070510.GE28591@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 19 Aug 2013 10:05:10 +0300

> We need to move the derefernce after the IS_ERR() check.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
