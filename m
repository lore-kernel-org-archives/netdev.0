From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Fix static checker warning regarding
 `txdata_ptr'
Date: Wed, 27 Aug 2014 16:29:11 -0700 (PDT)
Message-ID: <20140827.162911.2304971595773773996.davem@davemloft.net>
References: <1409037881-4192-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Ariel.Elior@qlogic.com, dan.carpenter@oracle.com
To: Yuval.Mintz@qlogic.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1409037881-4192-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Tue, 26 Aug 2014 10:24:41 +0300

> Incorrect checking of array instead of array contents in panic_dump
> flow - results of commit e261199872a2 ("bnx2x: Safe bnx2x_panic_dump()").
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied, thanks.
