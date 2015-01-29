From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] hisilicon: add some missing curly braces
Date: Wed, 28 Jan 2015 23:07:05 -0800 (PST)
Message-ID: <20150128.230705.155343650325772037.davem@davemloft.net>
References: <20150128185833.GA10259@mwanda>
	<54C99FFB.2080207@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, zhangfei.gao@linaro.org, arnd@arndb.de,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755584AbbA2HHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 02:07:06 -0500
In-Reply-To: <54C99FFB.2080207@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Thu, 29 Jan 2015 10:50:35 +0800

> On 2015/1/29 2:58, Dan Carpenter wrote:
>> The if block was supposed to have curly braces.  In the current code we
>> complain about dropped rx packets when we shouldn't.
>> 
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>> 
> Acked-by: Ding Tianhong <dingtianhong@huawei.com>

Applied, thanks everyone.
