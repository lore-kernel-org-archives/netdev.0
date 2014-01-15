From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] sctp: create helper function to enable|disable
 sackdelay
Date: Wed, 15 Jan 2014 09:10:16 -0500
Message-ID: <20140115141016.GA19718@neilslaptop.think-freely.org>
References: <52D653B1.4040708@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54777 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735AbaAOOKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 09:10:37 -0500
Content-Disposition: inline
In-Reply-To: <52D653B1.4040708@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 05:24:01PM +0800, Wang Weidong wrote:
> add sctp_spp_sackdelay_{enable|disable} helper function for
> avoiding code duplication. 
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Acked-by: Neil Horman <nhorman@tuxdriver.com>
