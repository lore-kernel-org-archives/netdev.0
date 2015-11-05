From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] qlogic: qed: fix error codes in qed_resc_alloc()
Date: Thu, 05 Nov 2015 13:40:04 -0500 (EST)
Message-ID: <20151105.134004.2208461190213502633.davem@davemloft.net>
References: <20151105084128.GC19405@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
	everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20151105084128.GC19405@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 5 Nov 2015 11:41:28 +0300

> We accidentally return success instead of -ENOMEM here.
> 
> Fixes: fe56b9e6a8d9 ('qed: Add module with basic common support')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
