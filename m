From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/5] cleanup on resource check
Date: Mon, 27 Oct 2014 19:16:49 -0400 (EDT)
Message-ID: <20141027.191649.1590284845604489883.davem@davemloft.net>
References: <1414116730-4590-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	varkab@cdac.in
To: varkabhadram@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbaJ0XQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 19:16:51 -0400
In-Reply-To: <1414116730-4590-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkabhadram@gmail.com>
Date: Fri, 24 Oct 2014 07:42:05 +0530

> This series removes the duplication of sanity check for
> platform_get_resource() return resource. It will be checked 
> with devm_ioremap_resource()
> 
> changes since v2:
> 	- Merge #1 and #2 patches into single patch
> 	- remove the comment
> 
> changes since v1:
> 	- remove NULL dereference on resource_size()

Series applied, thanks.
