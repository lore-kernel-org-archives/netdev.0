From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: remove a redundant NULL check
Date: Tue, 14 Jan 2014 18:19:45 -0800 (PST)
Message-ID: <20140114.181945.615823290540787555.davem@davemloft.net>
References: <20140113134608.GA5232@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140113134608.GA5232@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 13 Jan 2014 16:46:08 +0300

> It confuses Smatch when we check "sinit" for NULL and then non-NULL and
> that causes a false positive warning later.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
