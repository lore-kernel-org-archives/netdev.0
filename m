From: David Miller <davem@davemloft.net>
Subject: Re: [patch] qed: signedness bug in qed_dcbx_process_tlv()
Date: Mon, 23 May 2016 15:11:41 -0700 (PDT)
Message-ID: <20160523.151141.2041940312643695129.davem@davemloft.net>
References: <20160523101935.GA10712@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, sudarsana.kalluru@qlogic.com,
	Ariel.Elior@qlogic.com, everest-linux-l2@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160523101935.GA10712@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 23 May 2016 13:19:35 +0300

> "priority" needs to be signed for the error handling to work.
> 
> Fixes: 39651abd2814 ('qed: add support for dcbx.')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
