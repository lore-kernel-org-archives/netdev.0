From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dccp: make the request_retries minimum is 1
Date: Wed, 14 May 2014 15:34:43 -0400 (EDT)
Message-ID: <20140514.153443.298271641580751103.davem@davemloft.net>
References: <53718A36.1040907@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org, netdev@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbaENTep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 15:34:45 -0400
In-Reply-To: <53718A36.1040907@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Tue, 13 May 2014 10:57:58 +0800

> In Documentation/networking/dccp.txt points that request_retries
> should be greater than 0. So make the extra1 to be &one instead
> of &zero.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thank you.
