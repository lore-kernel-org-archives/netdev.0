From: David Miller <davem@davemloft.net>
Subject: Re: [patch] arcnet: cleanup sizeof parameter
Date: Fri, 19 Jul 2013 17:37:33 -0700 (PDT)
Message-ID: <20130719.173733.2234107766353018238.davem@davemloft.net>
References: <20130719054805.GB9729@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130719054805.GB9729@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 19 Jul 2013 08:48:05 +0300

> This patch doesn't change the compiled code because ARC_HDR_SIZE is 4
> and sizeof(int) is 4, but the intent was to use the header size and not
> the sizeof the header size.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
