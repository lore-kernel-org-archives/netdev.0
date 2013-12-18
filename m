From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] sctp: remove casting from function calls
 through ops structure
Date: Wed, 18 Dec 2013 08:59:09 -0500
Message-ID: <20131218135908.GA10471@neilslaptop.think-freely.org>
References: <52B1687F.8080502@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40696 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536Ab3LRN7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 08:59:30 -0500
Content-Disposition: inline
In-Reply-To: <52B1687F.8080502@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 05:18:55PM +0800, Wang Weidong wrote:
> remove the unnecessary cast.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
