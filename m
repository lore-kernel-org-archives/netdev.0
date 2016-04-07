From: David Miller <davem@davemloft.net>
Subject: Re: Backport Security Fix for CVE-2015-8787 to v4.1
Date: Thu, 07 Apr 2016 12:04:35 -0400 (EDT)
Message-ID: <20160407.120435.243163080503182667.davem@davemloft.net>
References: <570600DE.2030001@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kamatam@amazon.com, pablo@netfilter.org
To: machida.yuki@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbcDGQEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 12:04:38 -0400
In-Reply-To: <570600DE.2030001@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Date: Thu, 7 Apr 2016 15:40:30 +0900

> Hi David,
> 
> I conformed that a patch of CVE-2015-8787 not applied at v4.1.21.
> Could you please apply a patch for 4.1-stable ?
> 
> CVE-2015-8787
> Upstream commit 94f9cd81436c85d8c3a318ba92e236ede73752fc

I do not handle netfilter -stable submissions, the netfilter team does.
