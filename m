From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: rds: changing the return type from int to void
Date: Mon, 02 Nov 2015 15:35:59 -0500 (EST)
Message-ID: <20151102.153559.1108886505666645252.davem@davemloft.net>
References: <saurabh.truth@gmail.com>
	<1446214604-6437-1-git-send-email-saurabh.truth@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, chien.yen@oracle.com,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: saurabh.truth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446214604-6437-1-git-send-email-saurabh.truth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Saurabh Sengar <saurabh.truth@gmail.com>
Date: Fri, 30 Oct 2015 19:46:44 +0530

> as result of function rds_iw_flush_mr_pool is nowhere checked,
> changing its return type from int to void.
> also removing the unused variable rc as there is nothing to return
> 
> Signed-off-by: Saurabh Sengar <saurabh.truth@gmail.com>
> ---
> v2 :  modify patch description, as per the comments from Sergei Shtylyov

Applied, thanks.
