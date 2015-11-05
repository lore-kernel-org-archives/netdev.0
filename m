From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] qlogic: qed: fix a test for MODE_MF_SI
Date: Wed, 04 Nov 2015 22:06:37 -0500 (EST)
Message-ID: <20151104.220637.2147977492516549425.davem@davemloft.net>
References: <20151104132911.GE20966@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
	everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20151104132911.GE20966@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 4 Nov 2015 16:29:11 +0300

> MODE_MF_SI is 9.  We should be testing bit 9 instead of AND 0x9.
> 
> Fixes: fe56b9e6a8d9 ('qed: Add module with basic common support')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
